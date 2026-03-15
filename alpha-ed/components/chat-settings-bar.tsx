"use client"

import { Button } from "@/components/ui/button"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ExpertiseSelector } from "./expertise-selector"
import type { ConversationSettings, PersonalityType } from "@/lib/types"
import { getQuickPersonalityHint } from "@/lib/ai-system-prompts"
import { Sparkles, MessageSquareText, Brain, Cpu, ChevronDown } from "lucide-react"
import { cn } from "@/lib/utils"

interface ChatSettingsBarProps {
  settings: ConversationSettings
  onSettingsChange: (settings: ConversationSettings) => void
}

const personalityColors: Record<PersonalityType, string> = {
  friendly: "text-primary",
  professional: "text-blue-400",
  creative: "text-accent",
  analytical: "text-emerald-400",
}

export function ChatSettingsBar({ settings, onSettingsChange }: ChatSettingsBarProps) {
  return (
    <div className="flex items-center gap-2 px-4 py-2.5 border-b border-border/50 bg-card/20 backdrop-blur-sm overflow-x-auto">
      {/* System status indicator */}
      <div className="hidden sm:flex items-center gap-2 pr-3 border-r border-border/50">
        <Cpu className="h-3.5 w-3.5 text-primary glow-icon" />
        <span className="text-[10px] font-mono text-muted-foreground uppercase tracking-wider">Config</span>
      </div>

      {/* Personality selector */}
      <Popover>
        <PopoverTrigger asChild>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 gap-2 bg-secondary/30 border border-border/50 hover:border-primary/30 hover:bg-secondary/50 rounded-lg font-mono text-xs"
          >
            <Sparkles className={cn("h-3.5 w-3.5", personalityColors[settings.personality])} />
            <span className="capitalize">{settings.personality}</span>
            <ChevronDown className="h-3 w-3 text-muted-foreground" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-64 bg-card/95 backdrop-blur-xl border-border/50" align="start">
          <div className="space-y-3">
            <div>
              <Label className="text-xs font-mono uppercase tracking-wider text-primary">Neural Personality</Label>
              <p className="text-xs text-muted-foreground mt-1">{getQuickPersonalityHint(settings.personality)}</p>
            </div>
            <Select
              value={settings.personality}
              onValueChange={(value: PersonalityType) => onSettingsChange({ ...settings, personality: value })}
            >
              <SelectTrigger className="h-9 bg-secondary/30 border-border/50 font-mono text-sm">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="bg-card/95 backdrop-blur-xl border-border/50">
                <SelectItem value="friendly" className="font-mono">
                  Friendly
                </SelectItem>
                <SelectItem value="professional" className="font-mono">
                  Professional
                </SelectItem>
                <SelectItem value="creative" className="font-mono">
                  Creative
                </SelectItem>
                <SelectItem value="analytical" className="font-mono">
                  Analytical
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
        </PopoverContent>
      </Popover>

      {/* Response length selector */}
      <Popover>
        <PopoverTrigger asChild>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 gap-2 bg-secondary/30 border border-border/50 hover:border-primary/30 hover:bg-secondary/50 rounded-lg font-mono text-xs"
          >
            <MessageSquareText className="h-3.5 w-3.5 text-primary" />
            <span className="capitalize">{settings.responseLength}</span>
            <ChevronDown className="h-3 w-3 text-muted-foreground" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-64 bg-card/95 backdrop-blur-xl border-border/50" align="start">
          <div className="space-y-3">
            <Label className="text-xs font-mono uppercase tracking-wider text-primary">Output Length</Label>
            <Select
              value={settings.responseLength}
              onValueChange={(value: "concise" | "balanced" | "detailed") =>
                onSettingsChange({ ...settings, responseLength: value })
              }
            >
              <SelectTrigger className="h-9 bg-secondary/30 border-border/50 font-mono text-sm">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="bg-card/95 backdrop-blur-xl border-border/50">
                <SelectItem value="concise" className="font-mono">
                  Concise
                </SelectItem>
                <SelectItem value="balanced" className="font-mono">
                  Balanced
                </SelectItem>
                <SelectItem value="detailed" className="font-mono">
                  Detailed
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
        </PopoverContent>
      </Popover>

      {/* Expertise selector */}
      <Popover>
        <PopoverTrigger asChild>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 gap-2 bg-secondary/30 border border-border/50 hover:border-primary/30 hover:bg-secondary/50 rounded-lg font-mono text-xs"
          >
            <Brain className="h-3.5 w-3.5 text-primary" />
            <span>
              {settings.expertise.length} module{settings.expertise.length !== 1 ? "s" : ""}
            </span>
            <ChevronDown className="h-3 w-3 text-muted-foreground" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-80 bg-card/95 backdrop-blur-xl border-border/50" align="start">
          <div className="space-y-3">
            <div>
              <Label className="text-xs font-mono uppercase tracking-wider text-primary">Knowledge Modules</Label>
              <p className="text-xs text-muted-foreground mt-1">Activate specialized neural pathways</p>
            </div>
            <ExpertiseSelector
              selected={settings.expertise}
              onChange={(expertise) => onSettingsChange({ ...settings, expertise })}
            />
          </div>
        </PopoverContent>
      </Popover>
    </div>
  )
}
