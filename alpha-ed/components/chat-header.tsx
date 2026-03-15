"use client"

import { AlphaLogo } from "./alpha-logo"
import { Button } from "@/components/ui/button"
import { Plus, Menu, Settings, History, Radio, Activity } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { LiveModeIndicator } from "./live-mode-indicator"
import { cn } from "@/lib/utils"

interface ChatHeaderProps {
  onNewChat: () => void
  onOpenSettings: () => void
  onOpenHistory: () => void
  conversationTitle?: string
  isLiveMode?: boolean
  isListening?: boolean
  onToggleLiveMode?: () => void
}

export function ChatHeader({
  onNewChat,
  onOpenSettings,
  onOpenHistory,
  conversationTitle,
  isLiveMode,
  isListening,
  onToggleLiveMode,
}: ChatHeaderProps) {
  return (
    <header className="safe-top sticky top-0 z-50 border-b border-border/50 bg-background/60 backdrop-blur-xl">
      {/* Top accent line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent" />

      <div className="flex h-16 items-center justify-between px-4">
        {/* Left section */}
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="icon"
            className="h-10 w-10 rounded-xl border border-border/50 bg-card/30 hover:bg-card/50 hover:border-primary/30 transition-all"
            onClick={onOpenHistory}
          >
            <History className="h-5 w-5" />
            <span className="sr-only">Chat history</span>
          </Button>

          <div className="flex items-center gap-3">
            <div className="relative">
              <AlphaLogo className="h-10 w-10" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-gradient">
                  {conversationTitle && conversationTitle !== "New Chat"
                    ? conversationTitle.slice(0, 18) + (conversationTitle.length > 18 ? "..." : "")
                    : "ALPHA"}
                </h1>
                {/* Status dot */}
                <span className="h-2 w-2 rounded-full bg-emerald-400 orb-glow" />
              </div>
              <div className="flex items-center gap-2 text-[10px] font-mono text-muted-foreground uppercase tracking-wider">
                <Activity className="h-3 w-3 text-primary" />
                <span>AI Neural Core</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right section */}
        <div className="flex items-center gap-2">
          <LiveModeIndicator isActive={isLiveMode || false} isListening={isListening || false} />

          {onToggleLiveMode && (
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "h-10 w-10 rounded-xl border transition-all",
                isLiveMode
                  ? "border-primary bg-primary/20 text-primary live-mode-active"
                  : "border-border/50 bg-card/30 hover:bg-card/50 hover:border-primary/30",
              )}
              onClick={onToggleLiveMode}
            >
              <Radio className="h-5 w-5" />
              <span className="sr-only">{isLiveMode ? "Disable" : "Enable"} live mode</span>
            </Button>
          )}

          <Button
            variant="ghost"
            size="icon"
            className="h-10 w-10 rounded-xl border border-border/50 bg-card/30 hover:bg-card/50 hover:border-primary/30 transition-all"
            onClick={onNewChat}
          >
            <Plus className="h-5 w-5" />
            <span className="sr-only">New chat</span>
          </Button>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-10 w-10 rounded-xl border border-border/50 bg-card/30 hover:bg-card/50 hover:border-primary/30 transition-all"
              >
                <Menu className="h-5 w-5" />
                <span className="sr-only">Menu</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48 bg-card/95 backdrop-blur-xl border-border/50">
              <DropdownMenuItem onClick={onNewChat} className="gap-2">
                <Plus className="h-4 w-4 text-primary" />
                <span>New Chat</span>
              </DropdownMenuItem>
              <DropdownMenuItem onClick={onOpenHistory} className="gap-2">
                <History className="h-4 w-4 text-primary" />
                <span>History</span>
              </DropdownMenuItem>
              <DropdownMenuSeparator className="bg-border/50" />
              <DropdownMenuItem onClick={onOpenSettings} className="gap-2">
                <Settings className="h-4 w-4 text-primary" />
                <span>Settings</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Bottom accent line */}
      <div className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />
    </header>
  )
}
