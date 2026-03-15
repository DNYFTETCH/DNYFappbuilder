"use client"

import type React from "react"

import { Badge } from "@/components/ui/badge"
import type { ExpertiseArea } from "@/lib/types"
import { Code, PenTool, Calculator, FlaskConical, Briefcase, Palette, Languages, Sparkles } from "lucide-react"
import { cn } from "@/lib/utils"

interface ExpertiseSelectorProps {
  selected: ExpertiseArea[]
  onChange: (areas: ExpertiseArea[]) => void
}

const expertiseOptions: { id: ExpertiseArea; label: string; icon: React.ElementType; color: string }[] = [
  { id: "general", label: "General", icon: Sparkles, color: "text-primary" },
  { id: "coding", label: "Coding", icon: Code, color: "text-emerald-400" },
  { id: "writing", label: "Writing", icon: PenTool, color: "text-blue-400" },
  { id: "math", label: "Math", icon: Calculator, color: "text-yellow-400" },
  { id: "science", label: "Science", icon: FlaskConical, color: "text-green-400" },
  { id: "business", label: "Business", icon: Briefcase, color: "text-orange-400" },
  { id: "creative", label: "Creative", icon: Palette, color: "text-accent" },
  { id: "language", label: "Language", icon: Languages, color: "text-pink-400" },
]

export function ExpertiseSelector({ selected, onChange }: ExpertiseSelectorProps) {
  const toggleExpertise = (id: ExpertiseArea) => {
    if (selected.includes(id)) {
      if (selected.length > 1) {
        onChange(selected.filter((e) => e !== id))
      }
    } else {
      onChange([...selected, id])
    }
  }

  return (
    <div className="flex flex-wrap gap-2">
      {expertiseOptions.map((option) => {
        const isSelected = selected.includes(option.id)
        return (
          <Badge
            key={option.id}
            variant="outline"
            className={cn(
              "cursor-pointer transition-all font-mono text-[10px] uppercase tracking-wider px-3 py-1.5 rounded-lg border",
              isSelected
                ? "bg-primary/20 border-primary/50 text-primary"
                : "bg-secondary/30 border-border/50 text-muted-foreground hover:border-primary/30 hover:bg-secondary/50",
            )}
            onClick={() => toggleExpertise(option.id)}
          >
            <option.icon className={cn("h-3 w-3 mr-1.5", isSelected ? option.color : "")} />
            {option.label}
          </Badge>
        )
      })}
    </div>
  )
}
