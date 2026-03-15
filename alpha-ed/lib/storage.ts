import type { ChatConversation, UserSettings, ConversationSettings } from "./types"

const STORAGE_KEYS = {
  CONVERSATIONS: "alpha_conversations",
  SETTINGS: "alpha_settings",
  CURRENT_CHAT: "alpha_current_chat",
} as const

// Conversation Storage
export function getConversations(): ChatConversation[] {
  if (typeof window === "undefined") return []
  try {
    const data = localStorage.getItem(STORAGE_KEYS.CONVERSATIONS)
    return data ? JSON.parse(data) : []
  } catch {
    return []
  }
}

export function saveConversation(conversation: ChatConversation): void {
  if (typeof window === "undefined") return
  const conversations = getConversations()
  const index = conversations.findIndex((c) => c.id === conversation.id)

  if (index >= 0) {
    conversations[index] = conversation
  } else {
    conversations.unshift(conversation)
  }

  localStorage.setItem(STORAGE_KEYS.CONVERSATIONS, JSON.stringify(conversations))
}

export function deleteConversation(id: string): void {
  if (typeof window === "undefined") return
  const conversations = getConversations().filter((c) => c.id !== id)
  localStorage.setItem(STORAGE_KEYS.CONVERSATIONS, JSON.stringify(conversations))
}

export function clearAllConversations(): void {
  if (typeof window === "undefined") return
  localStorage.removeItem(STORAGE_KEYS.CONVERSATIONS)
}

export function createNewConversation(settings?: Partial<ConversationSettings>): ChatConversation {
  return {
    id: generateId(),
    title: "New Chat",
    messages: [],
    createdAt: Date.now(),
    updatedAt: Date.now(),
    settings: {
      personality: "friendly",
      responseLength: "balanced",
      expertise: ["general"],
      ...settings,
    },
  }
}

// Generate title from first message
export function generateTitle(message: string): string {
  const cleaned = message.trim().slice(0, 50)
  return cleaned.length < message.trim().length ? `${cleaned}...` : cleaned
}

// User Settings Storage
export function getUserSettings(): UserSettings {
  if (typeof window === "undefined") {
    return {
      displayName: "User",
      theme: "dark",
      defaultPersonality: "friendly",
      defaultResponseLength: "balanced",
      enableSoundEffects: true,
      enableHapticFeedback: true,
      saveHistory: true,
      autoDeleteDays: null,
      voiceEnabled: true,
      voiceSpeed: 1.0,
      voicePitch: 1.0,
      selectedVoice: "",
      autoSpeak: false,
      visionEnabled: true,
      liveModeEnabled: false,
    }
  }
  try {
    const data = localStorage.getItem(STORAGE_KEYS.SETTINGS)
    const defaults: UserSettings = {
      displayName: "User",
      theme: "dark",
      defaultPersonality: "friendly",
      defaultResponseLength: "balanced",
      enableSoundEffects: true,
      enableHapticFeedback: true,
      saveHistory: true,
      autoDeleteDays: null,
      voiceEnabled: true,
      voiceSpeed: 1.0,
      voicePitch: 1.0,
      selectedVoice: "",
      autoSpeak: false,
      visionEnabled: true,
      liveModeEnabled: false,
    }
    return data ? { ...defaults, ...JSON.parse(data) } : defaults
  } catch {
    return {
      displayName: "User",
      theme: "dark",
      defaultPersonality: "friendly",
      defaultResponseLength: "balanced",
      enableSoundEffects: true,
      enableHapticFeedback: true,
      saveHistory: true,
      autoDeleteDays: null,
      voiceEnabled: true,
      voiceSpeed: 1.0,
      voicePitch: 1.0,
      selectedVoice: "",
      autoSpeak: false,
      visionEnabled: true,
      liveModeEnabled: false,
    }
  }
}

export function saveUserSettings(settings: UserSettings): void {
  if (typeof window === "undefined") return
  localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings))
}

// Utility
export function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
}
