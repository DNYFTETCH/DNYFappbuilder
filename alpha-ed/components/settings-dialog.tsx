"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Slider } from "@/components/ui/slider"
import { getUserSettings, saveUserSettings, clearAllConversations } from "@/lib/storage"
import type { UserSettings, PersonalityType } from "@/lib/types"
import { User, Sparkles, Bell, Trash2, Shield, Mic, Camera, Radio, Settings, Cpu, Database } from "lucide-react"
import { cn } from "@/lib/utils"

interface SettingsDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onSettingsChange?: (settings: UserSettings) => void
  availableVoices?: SpeechSynthesisVoice[]
}

export function SettingsDialog({ open, onOpenChange, onSettingsChange, availableVoices = [] }: SettingsDialogProps) {
  const [settings, setSettings] = useState<UserSettings>(getUserSettings())
  const [activeTab, setActiveTab] = useState<"profile" | "ai" | "voice" | "vision" | "app" | "data">("profile")

  useEffect(() => {
    if (open) {
      setSettings(getUserSettings())
    }
  }, [open])

  const handleSave = () => {
    saveUserSettings(settings)
    onSettingsChange?.(settings)
    onOpenChange(false)
  }

  const handleClearHistory = () => {
    if (confirm("Are you sure you want to delete all chat history? This cannot be undone.")) {
      clearAllConversations()
      onOpenChange(false)
      window.location.reload()
    }
  }

  const tabs = [
    { id: "profile", label: "Profile", icon: User },
    { id: "ai", label: "Neural", icon: Sparkles },
    { id: "voice", label: "Voice", icon: Mic },
    { id: "vision", label: "Vision", icon: Camera },
    { id: "app", label: "System", icon: Bell },
    { id: "data", label: "Data", icon: Shield },
  ] as const

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md max-h-[85vh] overflow-hidden flex flex-col bg-background/95 backdrop-blur-xl border-border/50">
        {/* Header with gradient accent */}
        <div className="relative">
          <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent" />
        </div>

        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-gradient font-mono">
            <Settings className="h-5 w-5 text-primary glow-icon" />
            System Configuration
          </DialogTitle>
          <DialogDescription className="text-[10px] font-mono uppercase tracking-wider text-muted-foreground">
            Customize Alpha AI neural parameters
          </DialogDescription>
        </DialogHeader>

        {/* Tab navigation */}
        <div className="flex gap-1 border-b border-border/50 pb-2 overflow-x-auto">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                "flex items-center gap-1.5 px-3 py-2 rounded-lg text-[10px] font-mono uppercase tracking-wider transition-all whitespace-nowrap border",
                activeTab === tab.id
                  ? "bg-primary/20 text-primary border-primary/30"
                  : "text-muted-foreground hover:bg-secondary/30 border-transparent hover:border-border/50",
              )}
            >
              <tab.icon className="h-3.5 w-3.5" />
              {tab.label}
            </button>
          ))}
        </div>

        <div className="flex-1 overflow-y-auto py-4 space-y-6">
          {activeTab === "profile" && (
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="displayName" className="text-xs font-mono uppercase tracking-wider text-primary">
                  User Identity
                </Label>
                <Input
                  id="displayName"
                  value={settings.displayName}
                  onChange={(e) => setSettings({ ...settings, displayName: e.target.value })}
                  placeholder="Enter callsign..."
                  className="bg-secondary/30 border-border/50 font-mono focus:border-primary/50"
                />
                <p className="text-[10px] font-mono text-muted-foreground uppercase tracking-wider">
                  Alpha will address you by this identifier
                </p>
              </div>
            </div>
          )}

          {activeTab === "ai" && (
            <div className="space-y-4">
              <div className="space-y-2">
                <Label className="text-xs font-mono uppercase tracking-wider text-primary">
                  Neural Personality Matrix
                </Label>
                <Select
                  value={settings.defaultPersonality}
                  onValueChange={(value: PersonalityType) => setSettings({ ...settings, defaultPersonality: value })}
                >
                  <SelectTrigger className="bg-secondary/30 border-border/50 font-mono">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent className="bg-card/95 backdrop-blur-xl border-border/50">
                    <SelectItem value="friendly" className="font-mono">
                      Friendly - Warm interface
                    </SelectItem>
                    <SelectItem value="professional" className="font-mono">
                      Professional - Formal protocol
                    </SelectItem>
                    <SelectItem value="creative" className="font-mono">
                      Creative - Imaginative mode
                    </SelectItem>
                    <SelectItem value="analytical" className="font-mono">
                      Analytical - Logic core
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label className="text-xs font-mono uppercase tracking-wider text-primary">Output Verbosity</Label>
                <Select
                  value={settings.defaultResponseLength}
                  onValueChange={(value: "concise" | "balanced" | "detailed") =>
                    setSettings({ ...settings, defaultResponseLength: value })
                  }
                >
                  <SelectTrigger className="bg-secondary/30 border-border/50 font-mono">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent className="bg-card/95 backdrop-blur-xl border-border/50">
                    <SelectItem value="concise" className="font-mono">
                      Concise - Minimal output
                    </SelectItem>
                    <SelectItem value="balanced" className="font-mono">
                      Balanced - Standard output
                    </SelectItem>
                    <SelectItem value="detailed" className="font-mono">
                      Detailed - Maximum output
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="flex items-center justify-between pt-2 p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="flex items-center gap-2 text-xs font-mono uppercase tracking-wider">
                    <Radio className="h-4 w-4 text-primary glow-icon" />
                    Live Mode
                  </Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Real-time voice conversation</p>
                </div>
                <Switch
                  checked={settings.liveModeEnabled}
                  onCheckedChange={(checked) => setSettings({ ...settings, liveModeEnabled: checked })}
                />
              </div>
            </div>
          )}

          {activeTab === "voice" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="text-xs font-mono uppercase tracking-wider">Voice Synthesis</Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Enable TTS output</p>
                </div>
                <Switch
                  checked={settings.voiceEnabled}
                  onCheckedChange={(checked) => setSettings({ ...settings, voiceEnabled: checked })}
                />
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="text-xs font-mono uppercase tracking-wider">Auto-Vocalize</Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Speak responses automatically</p>
                </div>
                <Switch
                  checked={settings.autoSpeak}
                  onCheckedChange={(checked) => setSettings({ ...settings, autoSpeak: checked })}
                />
              </div>

              {settings.voiceEnabled && (
                <>
                  <div className="space-y-2">
                    <Label className="text-xs font-mono uppercase tracking-wider text-primary">Voice Module</Label>
                    <Select
                      value={settings.selectedVoice}
                      onValueChange={(value) => setSettings({ ...settings, selectedVoice: value })}
                    >
                      <SelectTrigger className="bg-secondary/30 border-border/50 font-mono text-sm">
                        <SelectValue placeholder="Select voice module" />
                      </SelectTrigger>
                      <SelectContent className="bg-card/95 backdrop-blur-xl border-border/50 max-h-48">
                        {availableVoices.map((voice) => (
                          <SelectItem key={voice.name} value={voice.name} className="font-mono text-xs">
                            {voice.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-xs font-mono uppercase tracking-wider text-primary">
                      Speed: {settings.voiceSpeed.toFixed(1)}x
                    </Label>
                    <Slider
                      value={[settings.voiceSpeed]}
                      min={0.5}
                      max={2}
                      step={0.1}
                      onValueChange={([value]) => setSettings({ ...settings, voiceSpeed: value })}
                      className="py-2"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-xs font-mono uppercase tracking-wider text-primary">
                      Pitch: {settings.voicePitch.toFixed(1)}
                    </Label>
                    <Slider
                      value={[settings.voicePitch]}
                      min={0.5}
                      max={2}
                      step={0.1}
                      onValueChange={([value]) => setSettings({ ...settings, voicePitch: value })}
                      className="py-2"
                    />
                  </div>
                </>
              )}
            </div>
          )}

          {activeTab === "vision" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="text-xs font-mono uppercase tracking-wider">Vision Module</Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Camera and image analysis</p>
                </div>
                <Switch
                  checked={settings.visionEnabled}
                  onCheckedChange={(checked) => setSettings({ ...settings, visionEnabled: checked })}
                />
              </div>

              <div className="p-4 rounded-xl bg-card/30 border border-primary/20 space-y-3">
                <h4 className="text-xs font-mono uppercase tracking-wider text-primary flex items-center gap-2">
                  <Camera className="h-4 w-4" />
                  Vision Capabilities
                </h4>
                <ul className="text-[10px] font-mono text-muted-foreground space-y-2">
                  <li className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                    Object recognition and identification
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                    Text extraction from images (OCR)
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                    Scene understanding and description
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                    Document and receipt scanning
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                    Visual question answering
                  </li>
                </ul>
              </div>
            </div>
          )}

          {activeTab === "app" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="text-xs font-mono uppercase tracking-wider">Audio Feedback</Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Interface sound effects</p>
                </div>
                <Switch
                  checked={settings.enableSoundEffects}
                  onCheckedChange={(checked) => setSettings({ ...settings, enableSoundEffects: checked })}
                />
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="text-xs font-mono uppercase tracking-wider">Haptic Response</Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Tactile interaction feedback</p>
                </div>
                <Switch
                  checked={settings.enableHapticFeedback}
                  onCheckedChange={(checked) => setSettings({ ...settings, enableHapticFeedback: checked })}
                />
              </div>
            </div>
          )}

          {activeTab === "data" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 rounded-xl bg-secondary/20 border border-border/50">
                <div>
                  <Label className="flex items-center gap-2 text-xs font-mono uppercase tracking-wider">
                    <Database className="h-4 w-4 text-primary" />
                    Memory Storage
                  </Label>
                  <p className="text-[10px] font-mono text-muted-foreground mt-1">Persist conversation data locally</p>
                </div>
                <Switch
                  checked={settings.saveHistory}
                  onCheckedChange={(checked) => setSettings({ ...settings, saveHistory: checked })}
                />
              </div>

              <div className="pt-4 border-t border-border/50">
                <Button
                  variant="destructive"
                  className="w-full rounded-xl font-mono text-xs uppercase tracking-wider"
                  onClick={handleClearHistory}
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Purge All Memory Data
                </Button>
                <p className="text-[10px] font-mono text-destructive/70 mt-2 text-center uppercase tracking-wider">
                  Warning: Irreversible operation
                </p>
              </div>
            </div>
          )}
        </div>

        <div className="flex gap-2 pt-4 border-t border-border/50">
          <Button
            variant="outline"
            className="flex-1 bg-secondary/30 border-border/50 hover:bg-secondary/50 hover:border-primary/30 rounded-xl font-mono text-xs uppercase tracking-wider"
            onClick={() => onOpenChange(false)}
          >
            Abort
          </Button>
          <Button
            className="flex-1 rounded-xl font-mono text-xs uppercase tracking-wider glow-border"
            onClick={handleSave}
          >
            <Cpu className="h-4 w-4 mr-2" />
            Apply Config
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
