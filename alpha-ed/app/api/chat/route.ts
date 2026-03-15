import { consumeStream, convertToModelMessages, streamText, type UIMessage } from "ai"
import { buildSystemPrompt } from "@/lib/ai-system-prompts"
import type { PersonalityType, ExpertiseArea } from "@/lib/types"

export const maxDuration = 60

interface ChatRequestBody {
  messages: UIMessage[]
  settings?: {
    personality?: PersonalityType
    expertise?: ExpertiseArea[]
    responseLength?: "concise" | "balanced" | "detailed"
    userName?: string
    hasVision?: boolean
    isLiveMode?: boolean
  }
}

export async function POST(req: Request) {
  const { messages, settings }: ChatRequestBody = await req.json()

  const personality = settings?.personality || "friendly"
  const expertise = settings?.expertise || ["general"]
  const responseLength = settings?.responseLength || "balanced"
  const userName = settings?.userName
  const hasVision = settings?.hasVision || false
  const isLiveMode = settings?.isLiveMode || false

  const systemPrompt = buildSystemPrompt(
    personality,
    expertise,
    isLiveMode ? "concise" : responseLength,
    userName,
    hasVision,
    isLiveMode,
  )
  const prompt = convertToModelMessages(messages)

  const model = hasVision ? "anthropic/claude-sonnet-4-20250514" : "anthropic/claude-sonnet-4-20250514"

  const result = streamText({
    model,
    system: systemPrompt,
    messages: prompt,
    abortSignal: req.signal,
    temperature: personality === "creative" ? 0.9 : personality === "analytical" ? 0.3 : 0.7,
    maxTokens: isLiveMode ? 300 : responseLength === "concise" ? 500 : responseLength === "detailed" ? 2000 : 1000,
  })

  return result.toUIMessageStreamResponse({
    onFinish: async ({ isAborted }) => {
      if (isAborted) {
        console.log("Request aborted")
      }
    },
    consumeSseStream: consumeStream,
  })
}
