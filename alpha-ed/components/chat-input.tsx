"use client"

import type React from "react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { ArrowUp, Square, Camera, ImagePlus, Sparkles, Cpu } from "lucide-react"
import { useRef, useEffect } from "react"
import { VoiceInputButton } from "./voice-input-button"
import { ImagePreview } from "./image-preview"

interface ChatInputProps {
  value: string
  onChange: (value: string) => void
  onSubmit: () => void
  onStop?: () => void
  isLoading: boolean
  disabled?: boolean
  isListening?: boolean
  isSpeaking?: boolean
  onToggleListen?: () => void
  onStopSpeaking?: () => void
  voiceSupported?: boolean
  onOpenCamera?: () => void
  cameraSupported?: boolean
  images?: string[]
  onRemoveImage?: (index: number) => void
  onAddImage?: () => void
  isLiveMode?: boolean
}

export function ChatInput({
  value,
  onChange,
  onSubmit,
  onStop,
  isLoading,
  disabled,
  isListening,
  isSpeaking,
  onToggleListen,
  onStopSpeaking,
  voiceSupported = false,
  onOpenCamera,
  cameraSupported = false,
  images = [],
  onRemoveImage,
  onAddImage,
  isLiveMode,
}: ChatInputProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = "auto"
      textareaRef.current.style.height = `${Math.min(textareaRef.current.scrollHeight, 200)}px`
    }
  }, [value])

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      if (!isLoading && (value.trim() || images.length > 0)) {
        onSubmit()
      }
    }
  }

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader()
      reader.onload = (event) => {
        const result = event.target?.result as string
        onAddImage?.()
      }
      reader.readAsDataURL(file)
    }
  }

  return (
    <div className="safe-bottom border-t border-border/50 bg-background/60 backdrop-blur-xl p-4">
      {/* Top accent line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />

      <div className="mx-auto max-w-3xl">
        {/* Input container with glow effect */}
        <div
          className={cn(
            "relative flex flex-col rounded-2xl border bg-card/30 backdrop-blur-sm overflow-hidden transition-all",
            isListening ? "border-primary/50 glow-border" : "border-border/50 hover:border-primary/30",
            isLiveMode && "border-primary/30",
          )}
        >
          {/* Image previews */}
          <ImagePreview images={images} onRemove={onRemoveImage || (() => {})} />

          <div className="flex items-end gap-2 p-3">
            {/* Camera button */}
            {cameraSupported && (
              <Button
                type="button"
                size="icon"
                variant="ghost"
                className="h-10 w-10 shrink-0 rounded-xl border border-border/50 bg-secondary/30 hover:bg-secondary/50 hover:border-primary/30 transition-all"
                onClick={onOpenCamera}
                disabled={disabled}
              >
                <Camera className="h-5 w-5" />
                <span className="sr-only">Open camera</span>
              </Button>
            )}

            {/* Hidden file input */}
            <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleFileSelect} />

            {/* Image upload button */}
            <Button
              type="button"
              size="icon"
              variant="ghost"
              className="h-10 w-10 shrink-0 rounded-xl border border-border/50 bg-secondary/30 hover:bg-secondary/50 hover:border-primary/30 transition-all"
              onClick={() => fileInputRef.current?.click()}
              disabled={disabled}
            >
              <ImagePlus className="h-5 w-5" />
              <span className="sr-only">Add image</span>
            </Button>

            {/* Text input */}
            <div className="flex-1 relative">
              <textarea
                ref={textareaRef}
                value={value}
                onChange={(e) => onChange(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder={isListening ? "Listening to your voice..." : "Enter command or message..."}
                disabled={disabled}
                rows={1}
                className={cn(
                  "w-full resize-none bg-transparent px-4 py-2.5 text-sm font-mono",
                  "placeholder:text-muted-foreground focus:outline-none",
                  "max-h-[200px] min-h-[40px]",
                  isListening && "placeholder:text-primary",
                )}
              />
              {isListening && (
                <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
                  <span className="h-1.5 w-1.5 rounded-full bg-primary voice-wave-1" />
                  <span className="h-2 w-1.5 rounded-full bg-primary voice-wave-2" />
                  <span className="h-2.5 w-1.5 rounded-full bg-primary voice-wave-3" />
                  <span className="h-2 w-1.5 rounded-full bg-primary voice-wave-4" />
                  <span className="h-1.5 w-1.5 rounded-full bg-primary voice-wave-5" />
                </div>
              )}
            </div>

            {/* Voice input button */}
            {voiceSupported && onToggleListen && onStopSpeaking && (
              <VoiceInputButton
                isListening={isListening || false}
                isSpeaking={isSpeaking || false}
                onToggleListen={onToggleListen}
                onStopSpeaking={onStopSpeaking}
                disabled={disabled}
                isSupported={voiceSupported}
              />
            )}

            {/* Submit/Stop button */}
            {isLoading ? (
              <Button
                type="button"
                size="icon"
                variant="destructive"
                className="h-10 w-10 shrink-0 rounded-xl"
                onClick={onStop}
              >
                <Square className="h-4 w-4 fill-current" />
                <span className="sr-only">Stop generating</span>
              </Button>
            ) : (
              <Button
                type="button"
                size="icon"
                className={cn(
                  "h-10 w-10 shrink-0 rounded-xl transition-all",
                  isLiveMode
                    ? "bg-gradient-to-br from-primary to-accent hover:opacity-90 glow-border"
                    : "bg-primary hover:bg-primary/90",
                )}
                disabled={(!value.trim() && images.length === 0) || disabled}
                onClick={onSubmit}
              >
                {isLiveMode ? <Sparkles className="h-4 w-4" /> : <ArrowUp className="h-4 w-4" />}
                <span className="sr-only">Send message</span>
              </Button>
            )}
          </div>
        </div>

        {/* Footer info */}
        <div className="mt-3 flex items-center justify-center gap-2 text-[10px] font-mono text-muted-foreground uppercase tracking-wider">
          <Cpu className="h-3 w-3 text-primary" />
          <span>Alpha Neural Engine</span>
          <span className="text-border">|</span>
          <span>Voice + Vision + Intelligence</span>
        </div>
      </div>
    </div>
  )
}
