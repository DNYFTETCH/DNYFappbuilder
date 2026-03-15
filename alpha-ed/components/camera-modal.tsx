"use client"

import type React from "react"

import { useEffect, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { SwitchCamera, X, Aperture, Scan, Eye } from "lucide-react"

interface CameraModalProps {
  isOpen: boolean
  onClose: () => void
  stream: MediaStream | null
  onCapture: () => void
  onSwitchCamera: () => void
  videoRef: React.RefObject<HTMLVideoElement | null>
  canvasRef: React.RefObject<HTMLCanvasElement | null>
  facingMode: "user" | "environment"
}

export function CameraModal({
  isOpen,
  onClose,
  stream,
  onCapture,
  onSwitchCamera,
  videoRef,
  canvasRef,
  facingMode,
}: CameraModalProps) {
  const localVideoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    const video = localVideoRef.current
    if (video && stream) {
      video.srcObject = stream
      video.play().catch(console.error)
    }
  }, [stream])

  useEffect(() => {
    if (videoRef && localVideoRef.current) {
      ;(videoRef as React.MutableRefObject<HTMLVideoElement | null>).current = localVideoRef.current
    }
  }, [videoRef])

  const handleCapture = () => {
    onCapture()
    onClose()
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-lg p-0 overflow-hidden bg-background/95 backdrop-blur-xl border-border/50">
        {/* Header with gradient accent */}
        <div className="relative">
          <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent" />

          <DialogHeader className="p-4 border-b border-border/50 bg-card/30">
            <DialogTitle className="flex items-center gap-2 text-gradient font-mono">
              <Eye className="h-5 w-5 text-primary glow-icon" />
              Vision Scanner
            </DialogTitle>
            <p className="text-[10px] font-mono text-muted-foreground uppercase tracking-wider mt-1">
              Object Recognition Active
            </p>
          </DialogHeader>
        </div>

        <div className="relative aspect-[4/3] bg-black">
          {/* Video feed */}
          <video
            ref={localVideoRef}
            autoPlay
            playsInline
            muted
            className="w-full h-full object-cover"
            style={{ transform: facingMode === "user" ? "scaleX(-1)" : "none" }}
          />
          <canvas ref={canvasRef} className="hidden" />

          {/* Scanning overlay */}
          <div className="absolute inset-0 pointer-events-none">
            {/* Corner brackets */}
            <svg className="absolute top-4 left-4 w-12 h-12 text-primary" viewBox="0 0 48 48">
              <path d="M0 16 L0 0 L16 0" fill="none" stroke="currentColor" strokeWidth="2" />
            </svg>
            <svg className="absolute top-4 right-4 w-12 h-12 text-primary" viewBox="0 0 48 48">
              <path d="M32 0 L48 0 L48 16" fill="none" stroke="currentColor" strokeWidth="2" />
            </svg>
            <svg className="absolute bottom-20 left-4 w-12 h-12 text-primary" viewBox="0 0 48 48">
              <path d="M0 32 L0 48 L16 48" fill="none" stroke="currentColor" strokeWidth="2" />
            </svg>
            <svg className="absolute bottom-20 right-4 w-12 h-12 text-primary" viewBox="0 0 48 48">
              <path d="M32 48 L48 48 L48 32" fill="none" stroke="currentColor" strokeWidth="2" />
            </svg>

            {/* Center focus indicator */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 border-2 border-primary/50 rounded-lg">
              <div className="absolute inset-2 border border-primary/30 rounded" />
              <Scan className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-6 w-6 text-primary animate-pulse" />
            </div>

            {/* Status indicators */}
            <div className="absolute top-4 left-1/2 -translate-x-1/2 flex items-center gap-2 px-3 py-1.5 rounded-full bg-background/60 backdrop-blur-sm border border-primary/30">
              <span className="h-2 w-2 rounded-full bg-emerald-400 orb-glow" />
              <span className="text-[10px] font-mono text-emerald-400 uppercase tracking-wider">Scanning</span>
            </div>
          </div>

          {/* Camera controls */}
          <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-background/90 to-transparent">
            <div className="flex items-center justify-center gap-6">
              {/* Switch camera */}
              <Button
                variant="ghost"
                size="icon"
                className="h-12 w-12 rounded-xl bg-secondary/50 border border-border/50 text-foreground hover:bg-secondary/70 hover:border-primary/30 backdrop-blur-sm transition-all"
                onClick={onSwitchCamera}
              >
                <SwitchCamera className="h-5 w-5" />
              </Button>

              {/* Capture button */}
              <Button
                size="icon"
                className="h-16 w-16 rounded-2xl bg-primary text-primary-foreground hover:bg-primary/90 glow-border transition-all relative"
                onClick={handleCapture}
              >
                <Aperture className="h-8 w-8" />
                {/* Pulse ring */}
                <span className="absolute inset-0 rounded-2xl border-2 border-primary animate-ping opacity-30" />
              </Button>

              {/* Close button */}
              <Button
                variant="ghost"
                size="icon"
                className="h-12 w-12 rounded-xl bg-secondary/50 border border-border/50 text-foreground hover:bg-destructive/20 hover:border-destructive/30 hover:text-destructive backdrop-blur-sm transition-all"
                onClick={onClose}
              >
                <X className="h-5 w-5" />
              </Button>
            </div>
          </div>
        </div>

        {/* Bottom accent line */}
        <div className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />
      </DialogContent>
    </Dialog>
  )
}
