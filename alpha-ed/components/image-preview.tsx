"use client"

import { Button } from "@/components/ui/button"
import { X, Eye, Scan } from "lucide-react"
import Image from "next/image"

interface ImagePreviewProps {
  images: string[]
  onRemove: (index: number) => void
}

export function ImagePreview({ images, onRemove }: ImagePreviewProps) {
  if (images.length === 0) return null

  return (
    <div className="flex gap-2 px-3 py-3 overflow-x-auto border-b border-border/50 bg-secondary/10">
      {images.map((image, index) => (
        <div key={index} className="relative shrink-0 group">
          {/* Image container with futuristic border */}
          <div className="relative h-20 w-20 rounded-xl overflow-hidden border border-primary/30 glow-border">
            <Image
              src={image || "/placeholder.svg"}
              alt={`Attached image ${index + 1}`}
              fill
              className="object-cover"
            />

            {/* Scanning overlay */}
            <div className="absolute inset-0 bg-gradient-to-t from-background/60 to-transparent" />

            {/* Corner brackets */}
            <svg className="absolute top-1 left-1 w-4 h-4 text-primary" viewBox="0 0 16 16">
              <path d="M0 6 L0 0 L6 0" fill="none" stroke="currentColor" strokeWidth="1.5" />
            </svg>
            <svg className="absolute top-1 right-1 w-4 h-4 text-primary" viewBox="0 0 16 16">
              <path d="M10 0 L16 0 L16 6" fill="none" stroke="currentColor" strokeWidth="1.5" />
            </svg>
            <svg className="absolute bottom-1 left-1 w-4 h-4 text-primary" viewBox="0 0 16 16">
              <path d="M0 10 L0 16 L6 16" fill="none" stroke="currentColor" strokeWidth="1.5" />
            </svg>
            <svg className="absolute bottom-1 right-1 w-4 h-4 text-primary" viewBox="0 0 16 16">
              <path d="M10 16 L16 16 L16 10" fill="none" stroke="currentColor" strokeWidth="1.5" />
            </svg>
          </div>

          {/* Remove button */}
          <Button
            variant="destructive"
            size="icon"
            className="absolute -top-2 -right-2 h-6 w-6 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity border border-destructive/50"
            onClick={() => onRemove(index)}
          >
            <X className="h-3 w-3" />
          </Button>

          {/* Vision badge */}
          <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 flex items-center gap-1 px-1.5 py-0.5 rounded bg-background/80 backdrop-blur-sm border border-primary/30">
            <Eye className="h-2.5 w-2.5 text-primary" />
            <span className="text-[8px] font-mono text-primary uppercase">Vision</span>
          </div>
        </div>
      ))}

      {/* Add indicator for pending scan */}
      <div className="flex items-center justify-center h-20 px-4 rounded-xl border border-dashed border-border/50 bg-secondary/10">
        <div className="flex flex-col items-center gap-1 text-muted-foreground">
          <Scan className="h-4 w-4" />
          <span className="text-[8px] font-mono uppercase tracking-wider">{images.length} queued</span>
        </div>
      </div>
    </div>
  )
}
