"use client"

import { cn } from "@/lib/utils"
import { Radio, Activity } from "lucide-react"

interface LiveModeIndicatorProps {
  isActive: boolean
  isListening: boolean
}

export function LiveModeIndicator({ isActive, isListening }: LiveModeIndicatorProps) {
  if (!isActive) return null

  return (
    <div
      className={cn(
        "flex items-center gap-2 px-3 py-1.5 rounded-full text-[10px] font-mono uppercase tracking-wider border backdrop-blur-sm",
        isListening
          ? "bg-red-500/10 text-red-400 border-red-500/30"
          : "bg-primary/10 text-primary border-primary/30 glow-border",
      )}
    >
      {/* Animated pulse dot */}
      <span className={cn("h-2 w-2 rounded-full", isListening ? "bg-red-400 animate-pulse" : "bg-primary orb-glow")} />

      {/* Status indicator */}
      <Radio className={cn("h-3 w-3", isListening && "animate-pulse")} />

      <span className="hidden sm:inline">Live Mode</span>

      {/* Signal strength indicator */}
      <div className="flex items-center gap-0.5">
        <span className={cn("h-1.5 w-0.5 rounded-full", isListening ? "bg-red-400" : "bg-primary")} />
        <span className={cn("h-2 w-0.5 rounded-full", isListening ? "bg-red-400" : "bg-primary")} />
        <span className={cn("h-2.5 w-0.5 rounded-full", isListening ? "bg-red-400" : "bg-primary")} />
      </div>

      {isListening && <Activity className="h-3 w-3 animate-pulse" />}
    </div>
  )
}
