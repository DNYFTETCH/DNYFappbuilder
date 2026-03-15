"use client"

import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { Mic, MicOff, VolumeX } from "lucide-react"

interface VoiceInputButtonProps {
  isListening: boolean
  isSpeaking: boolean
  onToggleListen: () => void
  onStopSpeaking: () => void
  disabled?: boolean
  isSupported: boolean
}

export function VoiceInputButton({
  isListening,
  isSpeaking,
  onToggleListen,
  onStopSpeaking,
  disabled,
  isSupported,
}: VoiceInputButtonProps) {
  if (!isSupported) return null

  return (
    <div className="flex gap-1.5">
      {isSpeaking && (
        <Button
          type="button"
          size="icon"
          variant="ghost"
          className="h-10 w-10 shrink-0 rounded-xl border border-primary/30 bg-primary/10 text-primary hover:bg-primary/20 transition-all"
          onClick={onStopSpeaking}
        >
          <VolumeX className="h-5 w-5" />
          <span className="sr-only">Stop speaking</span>
        </Button>
      )}

      <Button
        type="button"
        size="icon"
        variant="ghost"
        className={cn(
          "h-10 w-10 shrink-0 rounded-xl border transition-all relative overflow-hidden",
          isListening
            ? "bg-red-500/20 text-red-400 border-red-500/50 listening-pulse"
            : "border-border/50 bg-secondary/30 hover:bg-secondary/50 hover:border-primary/30",
        )}
        onClick={onToggleListen}
        disabled={disabled}
      >
        {isListening ? (
          <>
            <MicOff className="h-5 w-5 relative z-10" />
            {/* Animated background waves */}
            <div className="absolute inset-0 flex items-center justify-center gap-0.5 opacity-30">
              <span className="h-full w-1 bg-red-400 voice-wave-1" />
              <span className="h-full w-1 bg-red-400 voice-wave-2" />
              <span className="h-full w-1 bg-red-400 voice-wave-3" />
            </div>
          </>
        ) : (
          <Mic className="h-5 w-5" />
        )}
        <span className="sr-only">{isListening ? "Stop listening" : "Start voice input"}</span>
      </Button>
    </div>
  )
}
