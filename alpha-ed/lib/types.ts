// Core types for the Alpha AI application

export interface ChatConversation {
  id: string
  title: string
  messages: ChatMessageData[]
  createdAt: number
  updatedAt: number
  settings: ConversationSettings
}

export interface ChatMessageData {
  id: string
  role: "user" | "assistant" | "system"
  content: string
  timestamp: number
  metadata?: MessageMetadata
  attachments?: MessageAttachment[]
}

export interface MessageAttachment {
  type: "image" | "audio"
  url: string
  name?: string
  mimeType?: string
}

export interface MessageMetadata {
  model?: string
  tokens?: number
  responseTime?: number
  sentiment?: "positive" | "neutral" | "negative"
  voiceUsed?: boolean
  visionUsed?: boolean
}

export interface ConversationSettings {
  personality: PersonalityType
  responseLength: "concise" | "balanced" | "detailed"
  expertise: ExpertiseArea[]
}

export type PersonalityType = "friendly" | "professional" | "creative" | "analytical"

export type ExpertiseArea = "general" | "coding" | "writing" | "math" | "science" | "business" | "creative" | "language"

export interface UserSettings {
  displayName: string
  theme: "dark" | "light" | "system"
  defaultPersonality: PersonalityType
  defaultResponseLength: "concise" | "balanced" | "detailed"
  enableSoundEffects: boolean
  enableHapticFeedback: boolean
  saveHistory: boolean
  autoDeleteDays: number | null
  // Voice settings
  voiceEnabled: boolean
  voiceSpeed: number
  voicePitch: number
  selectedVoice: string
  autoSpeak: boolean
  // Vision settings
  visionEnabled: boolean
  // Live mode
  liveModeEnabled: boolean
}

export const DEFAULT_USER_SETTINGS: UserSettings = {
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

export const DEFAULT_CONVERSATION_SETTINGS: ConversationSettings = {
  personality: "friendly",
  responseLength: "balanced",
  expertise: ["general"],
}

export interface VoiceRecognitionResult {
  transcript: string
  confidence: number
  isFinal: boolean
}

export interface VisionAnalysisResult {
  description: string
  objects: string[]
  text?: string
}
