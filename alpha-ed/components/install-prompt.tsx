"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Download, X } from "lucide-react"
import { AlphaLogo } from "./alpha-logo"

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>
}

export function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null)
  const [showPrompt, setShowPrompt] = useState(false)
  const [dismissed, setDismissed] = useState(false)

  useEffect(() => {
    const handler = (e: Event) => {
      e.preventDefault()
      setDeferredPrompt(e as BeforeInstallPromptEvent)
      setShowPrompt(true)
    }

    window.addEventListener("beforeinstallprompt", handler)
    return () => window.removeEventListener("beforeinstallprompt", handler)
  }, [])

  const handleInstall = async () => {
    if (!deferredPrompt) return

    await deferredPrompt.prompt()
    const { outcome } = await deferredPrompt.userChoice

    if (outcome === "accepted") {
      setShowPrompt(false)
    }
    setDeferredPrompt(null)
  }

  const handleDismiss = () => {
    setShowPrompt(false)
    setDismissed(true)
  }

  if (!showPrompt || dismissed) return null

  return (
    <div className="fixed bottom-24 left-4 right-4 z-50 mx-auto max-w-md animate-in slide-in-from-bottom-4">
      <div className="relative flex items-center gap-4 rounded-2xl border border-border/50 bg-card/95 backdrop-blur-xl p-4 shadow-xl glow-border">
        {/* Top accent line */}
        <div className="absolute top-0 left-4 right-4 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent" />

        {/* Logo */}
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-primary/10 border border-primary/30">
          <AlphaLogo className="h-7 w-7" animated={false} />
        </div>

        {/* Content */}
        <div className="flex-1">
          <p className="text-sm font-bold text-gradient">Install Alpha AI</p>
          <p className="text-[10px] font-mono text-muted-foreground uppercase tracking-wider mt-0.5">
            Add to home screen for native experience
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          <Button
            size="icon"
            variant="ghost"
            className="h-9 w-9 rounded-xl border border-border/50 bg-secondary/30 hover:bg-destructive/20 hover:border-destructive/30 hover:text-destructive"
            onClick={handleDismiss}
          >
            <X className="h-4 w-4" />
          </Button>
          <Button
            size="sm"
            className="rounded-xl bg-primary hover:bg-primary/90 glow-border gap-2 font-mono text-xs uppercase tracking-wider"
            onClick={handleInstall}
          >
            <Download className="h-4 w-4" />
            Install
          </Button>
        </div>

        {/* Bottom accent line */}
        <div className="absolute bottom-0 left-4 right-4 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />
      </div>
    </div>
  )
}
