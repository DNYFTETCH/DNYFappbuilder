"use client"

import { cn } from "@/lib/utils"
import { AlphaLogo } from "./alpha-logo"
import { User, Copy, Check, Volume2, Eye, Cpu } from "lucide-react"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import ReactMarkdown from "react-markdown"
import Image from "next/image"
import type { MessageAttachment } from "@/lib/types"

interface ChatMessageProps {
  role: "user" | "assistant"
  content: string
  isStreaming?: boolean
  timestamp?: number
  onSpeak?: (text: string) => void
  isSpeaking?: boolean
  attachments?: MessageAttachment[]
}

export function ChatMessage({
  role,
  content,
  isStreaming,
  timestamp,
  onSpeak,
  isSpeaking,
  attachments,
}: ChatMessageProps) {
  const [copied, setCopied] = useState(false)
  const isUser = role === "user"

  const handleCopy = async () => {
    await navigator.clipboard.writeText(content)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const handleSpeak = () => {
    onSpeak?.(content)
  }

  return (
    <div className={cn("flex gap-3 px-4 py-5 group", isUser ? "flex-row-reverse" : "flex-row")}>
      {/* Avatar */}
      <div
        className={cn(
          "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border transition-all",
          isUser ? "bg-secondary border-border/50" : "bg-card/50 border-primary/30 glow-border",
        )}
      >
        {isUser ? (
          <User className="h-5 w-5 text-secondary-foreground" />
        ) : (
          <AlphaLogo className="h-6 w-6" animated={isStreaming} />
        )}
      </div>

      {/* Message content */}
      <div
        className={cn(
          "flex max-w-[85%] flex-col gap-2 rounded-2xl px-4 py-3 relative",
          isUser
            ? "bg-primary text-primary-foreground rounded-br-sm"
            : "bg-card/50 border border-border/50 rounded-bl-sm backdrop-blur-sm",
        )}
      >
        {/* AI label for assistant messages */}
        {!isUser && (
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-primary uppercase tracking-wider mb-1">
            <Cpu className="h-3 w-3" />
            <span>Alpha Response</span>
            {isStreaming && (
              <span className="flex items-center gap-1 ml-2 text-muted-foreground">
                <span className="h-1.5 w-1.5 rounded-full bg-primary animate-pulse" />
                Processing
              </span>
            )}
          </div>
        )}

        {/* Image attachments */}
        {attachments && attachments.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-2">
            {attachments
              .filter((a) => a.type === "image")
              .map((attachment, index) => (
                <div
                  key={index}
                  className="relative h-36 w-36 rounded-xl overflow-hidden border border-border/50 glow-border"
                >
                  <Image
                    src={attachment.url || "/placeholder.svg"}
                    alt={attachment.name || "Attached image"}
                    fill
                    className="object-cover"
                  />
                  <div className="absolute bottom-1.5 right-1.5 bg-background/80 backdrop-blur-sm rounded-lg px-2 py-1 flex items-center gap-1.5 border border-primary/30">
                    <Eye className="h-3 w-3 text-primary" />
                    <span className="text-[10px] font-mono text-primary uppercase">Vision</span>
                  </div>
                </div>
              ))}
          </div>
        )}

        {/* Text content */}
        {isUser ? (
          <p className="text-sm leading-relaxed whitespace-pre-wrap">{content}</p>
        ) : (
          <div className="text-sm leading-relaxed prose prose-sm prose-invert max-w-none">
            <ReactMarkdown
              components={{
                p: ({ children }) => <p className="mb-3 last:mb-0">{children}</p>,
                ul: ({ children }) => <ul className="list-disc pl-4 mb-3 space-y-1">{children}</ul>,
                ol: ({ children }) => <ol className="list-decimal pl-4 mb-3 space-y-1">{children}</ol>,
                li: ({ children }) => <li className="mb-1">{children}</li>,
                code: ({ children, className }) => {
                  const isBlock = className?.includes("language-")
                  if (isBlock) {
                    return (
                      <pre className="bg-background/80 rounded-xl p-4 overflow-x-auto my-3 border border-border/50">
                        <code className="text-xs font-mono text-primary">{children}</code>
                      </pre>
                    )
                  }
                  return (
                    <code className="bg-primary/10 text-primary px-1.5 py-0.5 rounded-md text-xs font-mono">
                      {children}
                    </code>
                  )
                },
                h1: ({ children }) => <h1 className="text-lg font-bold mb-3 text-gradient">{children}</h1>,
                h2: ({ children }) => <h2 className="text-base font-bold mb-2 text-gradient">{children}</h2>,
                h3: ({ children }) => <h3 className="text-sm font-bold mb-2 text-primary">{children}</h3>,
                strong: ({ children }) => <strong className="font-semibold text-primary">{children}</strong>,
                blockquote: ({ children }) => (
                  <blockquote className="border-l-2 border-primary/50 pl-4 italic my-3 text-muted-foreground">
                    {children}
                  </blockquote>
                ),
              }}
            >
              {content}
            </ReactMarkdown>
          </div>
        )}

        {/* Streaming indicator */}
        {isStreaming && (
          <div className="flex items-center gap-1.5 mt-1">
            <span className="h-2 w-2 rounded-full bg-primary animate-pulse" />
            <span className="h-2 w-2 rounded-full bg-primary animate-pulse" style={{ animationDelay: "0.15s" }} />
            <span className="h-2 w-2 rounded-full bg-primary animate-pulse" style={{ animationDelay: "0.3s" }} />
          </div>
        )}

        {/* Action buttons for assistant messages */}
        {!isUser && !isStreaming && (
          <div className="absolute -bottom-10 left-0 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-lg border border-border/50 bg-card/50 hover:bg-card hover:border-primary/30"
              onClick={handleCopy}
            >
              {copied ? <Check className="h-3.5 w-3.5 text-emerald-400" /> : <Copy className="h-3.5 w-3.5" />}
            </Button>
            {onSpeak && (
              <Button
                variant="ghost"
                size="icon"
                className={cn(
                  "h-8 w-8 rounded-lg border border-border/50 bg-card/50 hover:bg-card hover:border-primary/30",
                  isSpeaking && "border-primary/50 bg-primary/10",
                )}
                onClick={handleSpeak}
              >
                <Volume2 className={cn("h-3.5 w-3.5", isSpeaking && "text-primary")} />
              </Button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
