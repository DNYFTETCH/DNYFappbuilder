"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { ScrollArea } from "@/components/ui/scroll-area"
import { getConversations, deleteConversation } from "@/lib/storage"
import type { ChatConversation } from "@/lib/types"
import { MessageSquare, Trash2, Clock, Sparkles, Search, Camera, Mic, Database } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { cn } from "@/lib/utils"

interface HistoryDrawerProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onSelectConversation: (conversation: ChatConversation) => void
  currentConversationId?: string
}

export function HistoryDrawer({ open, onOpenChange, onSelectConversation, currentConversationId }: HistoryDrawerProps) {
  const [conversations, setConversations] = useState<ChatConversation[]>([])
  const [searchQuery, setSearchQuery] = useState("")

  useEffect(() => {
    if (open) {
      setConversations(getConversations())
      setSearchQuery("")
    }
  }, [open])

  const handleDelete = (id: string, e: React.MouseEvent) => {
    e.stopPropagation()
    if (confirm("Delete this conversation?")) {
      deleteConversation(id)
      setConversations(conversations.filter((c) => c.id !== id))
    }
  }

  const filteredConversations = conversations.filter(
    (c) =>
      c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.messages.some((m) => m.content.toLowerCase().includes(searchQuery.toLowerCase())),
  )

  const getPersonalityColor = (personality: string) => {
    switch (personality) {
      case "creative":
        return "text-accent"
      case "professional":
        return "text-blue-400"
      case "analytical":
        return "text-emerald-400"
      default:
        return "text-primary"
    }
  }

  const getConversationFeatures = (conversation: ChatConversation) => {
    const features: React.ReactNode[] = []
    const hasImages = conversation.messages.some((m) => m.metadata?.visionUsed)
    const hasVoice = conversation.messages.some((m) => m.metadata?.voiceUsed)

    if (hasImages) {
      features.push(<Camera key="camera" className="h-3 w-3" />)
    }
    if (hasVoice) {
      features.push(<Mic key="mic" className="h-3 w-3" />)
    }
    return features
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="left" className="w-80 p-0 bg-background/95 backdrop-blur-xl border-border/50">
        {/* Header with gradient accent */}
        <div className="relative">
          <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent" />

          <SheetHeader className="p-4 border-b border-border/50">
            <SheetTitle className="flex items-center gap-2 text-gradient font-mono">
              <Database className="h-5 w-5 text-primary glow-icon" />
              Memory Bank
            </SheetTitle>
            <SheetDescription className="text-[10px] font-mono uppercase tracking-wider text-muted-foreground">
              {conversations.length} conversations stored
            </SheetDescription>
          </SheetHeader>
        </div>

        {/* Search bar with futuristic styling */}
        <div className="p-3 border-b border-border/50">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-primary" />
            <Input
              placeholder="Search memory..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-9 h-10 bg-secondary/30 border-border/50 font-mono text-sm placeholder:text-muted-foreground focus:border-primary/50 focus:ring-primary/20"
            />
          </div>
        </div>

        <ScrollArea className="h-[calc(100vh-180px)]">
          {filteredConversations.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
              <div className="h-16 w-16 rounded-2xl border border-border/50 bg-card/30 flex items-center justify-center mb-4 glow-border">
                <MessageSquare className="h-8 w-8 text-muted-foreground/50" />
              </div>
              <p className="text-sm font-medium text-muted-foreground">
                {searchQuery ? "No matching records" : "Memory bank empty"}
              </p>
              <p className="text-[10px] font-mono text-muted-foreground/70 mt-2 uppercase tracking-wider">
                {searchQuery ? "Adjust search parameters" : "Initialize new conversation"}
              </p>
            </div>
          ) : (
            <div className="p-2 space-y-2">
              {filteredConversations.map((conversation, index) => (
                <button
                  key={conversation.id}
                  onClick={() => {
                    onSelectConversation(conversation)
                    onOpenChange(false)
                  }}
                  className={cn(
                    "w-full flex items-start gap-3 p-3 rounded-xl text-left transition-all group",
                    currentConversationId === conversation.id
                      ? "bg-primary/10 border border-primary/30 glow-border"
                      : "bg-card/30 border border-border/50 hover:border-primary/30 hover:bg-card/50",
                  )}
                >
                  {/* Index number */}
                  <div className="flex flex-col items-center gap-1">
                    <span className="text-[10px] font-mono text-muted-foreground">
                      {String(index + 1).padStart(2, "0")}
                    </span>
                    <Sparkles className={cn("h-4 w-4", getPersonalityColor(conversation.settings.personality))} />
                  </div>

                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{conversation.title}</p>
                    <div className="flex items-center gap-2 mt-1.5">
                      <Clock className="h-3 w-3 text-muted-foreground" />
                      <span className="text-[10px] font-mono text-muted-foreground uppercase">
                        {formatDistanceToNow(conversation.updatedAt, { addSuffix: true })}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-[10px] font-mono text-primary px-1.5 py-0.5 rounded bg-primary/10 border border-primary/20">
                        {conversation.messages.length} msgs
                      </span>
                      <div className="flex items-center gap-1 text-muted-foreground">
                        {getConversationFeatures(conversation)}
                      </div>
                    </div>
                  </div>

                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8 opacity-0 group-hover:opacity-100 shrink-0 rounded-lg border border-destructive/30 bg-destructive/10 hover:bg-destructive/20 text-destructive"
                    onClick={(e) => handleDelete(conversation.id, e)}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </button>
              ))}
            </div>
          )}
        </ScrollArea>

        {/* Bottom accent line */}
        <div className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />
      </SheetContent>
    </Sheet>
  )
}
