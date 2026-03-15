"use client"

import { useState, useRef, useEffect, useCallback } from "react"
import { useChat } from "@ai-sdk/react"
import { DefaultChatTransport } from "ai"
import { ChatHeader } from "@/components/chat-header"
import { ChatMessage } from "@/components/chat-message"
import { ChatInput } from "@/components/chat-input"
import { WelcomeScreen } from "@/components/welcome-screen"
import { InstallPrompt } from "@/components/install-prompt"
import { SettingsDialog } from "@/components/settings-dialog"
import { HistoryDrawer } from "@/components/history-drawer"
import { ChatSettingsBar } from "@/components/chat-settings-bar"
import { CameraModal } from "@/components/camera-modal"
import { FuturisticBackground } from "@/components/futuristic-background"
import { saveConversation, createNewConversation, generateTitle, getUserSettings } from "@/lib/storage"
import { useSpeech } from "@/hooks/use-speech"
import { useCamera } from "@/hooks/use-camera"
import type { ChatConversation, ConversationSettings, UserSettings, MessageAttachment } from "@/lib/types"

export default function AlphaChat() {
  const [input, setInput] = useState("")
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [historyOpen, setHistoryOpen] = useState(false)
  const [userSettings, setUserSettings] = useState<UserSettings | null>(null)
  const [currentConversation, setCurrentConversation] = useState<ChatConversation | null>(null)
  const [chatSettings, setChatSettings] = useState<ConversationSettings>({
    personality: "friendly",
    responseLength: "balanced",
    expertise: ["general"],
  })
  const [pendingImages, setPendingImages] = useState<string[]>([])
  const [isLiveMode, setIsLiveMode] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const settings = getUserSettings()
    setUserSettings(settings)
    setChatSettings({
      personality: settings.defaultPersonality,
      responseLength: settings.defaultResponseLength,
      expertise: ["general"],
    })
    setIsLiveMode(settings.liveModeEnabled)
  }, [])

  const handleTranscript = useCallback(
    (text: string, isFinal: boolean) => {
      if (isFinal && isLiveMode) {
        setInput(text)
        setTimeout(() => {
          if (text.trim()) {
            handleSubmitWithText(text)
          }
        }, 100)
      } else {
        setInput(text)
      }
    },
    [isLiveMode],
  )

  const {
    isListening,
    isSpeaking,
    voices,
    isSupported: speechSupported,
    startListening,
    stopListening,
    speak,
    stopSpeaking,
  } = useSpeech({
    settings: userSettings,
    onTranscript: handleTranscript,
  })

  const {
    isOpen: cameraOpen,
    stream,
    isSupported: cameraSupported,
    facingMode,
    videoRef,
    canvasRef,
    openCamera,
    closeCamera,
    switchCamera,
    capturePhoto,
  } = useCamera({
    onCapture: (imageData) => {
      setPendingImages((prev) => [...prev, imageData])
    },
  })

  const { messages, sendMessage, status, setMessages, stop } = useChat({
    transport: new DefaultChatTransport({ api: "/api/chat" }),
    body: {
      settings: {
        ...chatSettings,
        userName: userSettings?.displayName,
        hasVision: pendingImages.length > 0,
        isLiveMode,
      },
    },
  })

  const isLoading = status === "streaming" || status === "submitted"

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  useEffect(() => {
    if (!userSettings?.voiceEnabled) return
    if (!userSettings.autoSpeak && !isLiveMode) return

    const lastMessage = messages[messages.length - 1]
    if (lastMessage?.role === "assistant" && status === "ready") {
      const content = lastMessage.parts
        .filter((p) => p.type === "text")
        .map((p) => (p as { type: "text"; text: string }).text)
        .join("")
      if (content) {
        speak(content)
      }
    }
  }, [messages, status, userSettings, speak, isLiveMode])

  useEffect(() => {
    if (messages.length > 0 && userSettings?.saveHistory) {
      const conversation: ChatConversation = currentConversation || createNewConversation(chatSettings)

      if (conversation.title === "New Chat" && messages.length >= 1) {
        const firstUserMessage = messages.find((m) => m.role === "user")
        if (firstUserMessage) {
          const textContent = firstUserMessage.parts
            .filter((p) => p.type === "text")
            .map((p) => (p as { type: "text"; text: string }).text)
            .join("")
          conversation.title = generateTitle(textContent)
        }
      }

      conversation.messages = messages.map((m) => ({
        id: m.id,
        role: m.role as "user" | "assistant",
        content: m.parts
          .filter((p) => p.type === "text")
          .map((p) => (p as { type: "text"; text: string }).text)
          .join(""),
        timestamp: Date.now(),
      }))
      conversation.updatedAt = Date.now()
      conversation.settings = chatSettings

      saveConversation(conversation)
      if (!currentConversation) {
        setCurrentConversation(conversation)
      }
    }
  }, [messages, chatSettings, currentConversation, userSettings?.saveHistory])

  const handleSubmitWithText = (text: string) => {
    if (!text.trim() && pendingImages.length === 0) return
    if (isLoading) return

    const parts: Array<{ type: "text"; text: string } | { type: "image"; image: string }> = []

    pendingImages.forEach((img) => {
      parts.push({ type: "image", image: img })
    })

    if (text.trim()) {
      parts.push({ type: "text", text: text.trim() })
    }

    sendMessage({ parts })
    setInput("")
    setPendingImages([])

    if (isListening) {
      stopListening()
    }
  }

  const handleSubmit = () => {
    handleSubmitWithText(input)
  }

  const handleNewChat = () => {
    setMessages([])
    setInput("")
    setPendingImages([])
    setCurrentConversation(null)
    stopSpeaking()
    if (userSettings) {
      setChatSettings({
        personality: userSettings.defaultPersonality,
        responseLength: userSettings.defaultResponseLength,
        expertise: ["general"],
      })
    }
  }

  const handleSelectConversation = (conversation: ChatConversation) => {
    setCurrentConversation(conversation)
    setChatSettings(conversation.settings)
    const restoredMessages = conversation.messages.map((m) => ({
      id: m.id,
      role: m.role,
      parts: [{ type: "text" as const, text: m.content }],
      createdAt: new Date(m.timestamp),
    }))
    setMessages(restoredMessages)
  }

  const handleSuggestionClick = (text: string) => {
    setInput(text)
  }

  const handleSettingsChange = (settings: UserSettings) => {
    setUserSettings(settings)
    setIsLiveMode(settings.liveModeEnabled)
  }

  const handleToggleListen = () => {
    if (isListening) {
      stopListening()
    } else {
      startListening()
    }
  }

  const handleToggleLiveMode = () => {
    const newLiveMode = !isLiveMode
    setIsLiveMode(newLiveMode)
    if (userSettings) {
      setUserSettings({ ...userSettings, liveModeEnabled: newLiveMode })
    }
    if (newLiveMode && !isListening) {
      startListening()
    } else if (!newLiveMode && isListening) {
      stopListening()
    }
  }

  const handleCameraCapture = () => {
    capturePhoto()
  }

  const handleRemoveImage = (index: number) => {
    setPendingImages((prev) => prev.filter((_, i) => i !== index))
  }

  const handleSpeak = (text: string) => {
    if (isSpeaking) {
      stopSpeaking()
    } else {
      speak(text)
    }
  }

  if (!userSettings) {
    return (
      <div className="flex h-dvh items-center justify-center bg-background relative">
        <FuturisticBackground />
        <div className="relative z-10 flex flex-col items-center gap-4">
          <div className="h-12 w-12 rounded-xl border border-primary/30 bg-card/50 flex items-center justify-center glow-border">
            <div className="h-6 w-6 border-2 border-primary border-t-transparent rounded-full ai-thinking" />
          </div>
          <p className="text-sm font-mono text-muted-foreground uppercase tracking-wider">
            Initializing Neural Core...
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-dvh flex-col bg-background relative">
      <FuturisticBackground />

      {/* Main content with z-index to appear above background */}
      <div className="relative z-10 flex h-full flex-col">
        <ChatHeader
          onNewChat={handleNewChat}
          onOpenSettings={() => setSettingsOpen(true)}
          onOpenHistory={() => setHistoryOpen(true)}
          conversationTitle={currentConversation?.title}
          isLiveMode={isLiveMode}
          isListening={isListening}
          onToggleLiveMode={handleToggleLiveMode}
        />

        <ChatSettingsBar settings={chatSettings} onSettingsChange={setChatSettings} />

        <main className="flex flex-1 flex-col overflow-hidden">
          {messages.length === 0 ? (
            <WelcomeScreen onSuggestionClick={handleSuggestionClick} userName={userSettings.displayName} />
          ) : (
            <div className="flex-1 overflow-y-auto">
              <div className="mx-auto max-w-3xl py-4">
                {messages.map((message) => {
                  const content = message.parts
                    .filter((part) => part.type === "text")
                    .map((part) => (part as { type: "text"; text: string }).text)
                    .join("")

                  const imageAttachments: MessageAttachment[] = message.parts
                    .filter((part) => part.type === "image")
                    .map((part) => ({
                      type: "image" as const,
                      url: (part as { type: "image"; image: string }).image,
                    }))

                  return (
                    <ChatMessage
                      key={message.id}
                      role={message.role as "user" | "assistant"}
                      content={content}
                      attachments={imageAttachments}
                      isStreaming={
                        status === "streaming" &&
                        message.id === messages[messages.length - 1]?.id &&
                        message.role === "assistant"
                      }
                      onSpeak={message.role === "assistant" ? handleSpeak : undefined}
                      isSpeaking={isSpeaking}
                    />
                  )
                })}
                <div ref={messagesEndRef} />
              </div>
            </div>
          )}
        </main>

        <ChatInput
          value={input}
          onChange={setInput}
          onSubmit={handleSubmit}
          onStop={stop}
          isLoading={isLoading}
          isListening={isListening}
          isSpeaking={isSpeaking}
          onToggleListen={handleToggleListen}
          onStopSpeaking={stopSpeaking}
          voiceSupported={speechSupported.stt}
          onOpenCamera={openCamera}
          cameraSupported={cameraSupported && userSettings.visionEnabled}
          images={pendingImages}
          onRemoveImage={handleRemoveImage}
          isLiveMode={isLiveMode}
        />
      </div>

      <InstallPrompt />

      <SettingsDialog
        open={settingsOpen}
        onOpenChange={setSettingsOpen}
        onSettingsChange={handleSettingsChange}
        availableVoices={voices}
      />

      <HistoryDrawer
        open={historyOpen}
        onOpenChange={setHistoryOpen}
        onSelectConversation={handleSelectConversation}
        currentConversationId={currentConversation?.id}
      />

      <CameraModal
        isOpen={cameraOpen}
        onClose={closeCamera}
        stream={stream}
        onCapture={handleCameraCapture}
        onSwitchCamera={switchCamera}
        videoRef={videoRef}
        canvasRef={canvasRef}
        facingMode={facingMode}
      />
    </div>
  )
}
