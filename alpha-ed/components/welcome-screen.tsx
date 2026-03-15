"use client"

import { AlphaLogo } from "./alpha-logo"
import {
  Sparkles,
  Code,
  Lightbulb,
  MessageSquare,
  PenTool,
  Calculator,
  Brain,
  Zap,
  Mic,
  Camera,
  Radio,
  Eye,
  Cpu,
  Globe,
  Shield,
} from "lucide-react"

interface WelcomeScreenProps {
  onSuggestionClick: (text: string) => void
  userName?: string
}

const suggestions = [
  {
    icon: Brain,
    text: "Explain a complex topic in simple terms",
    category: "Learning",
  },
  {
    icon: Code,
    text: "Help me debug this code and explain the fix",
    category: "Coding",
  },
  {
    icon: PenTool,
    text: "Write a professional email for me",
    category: "Writing",
  },
  {
    icon: Lightbulb,
    text: "Brainstorm creative solutions for my problem",
    category: "Creative",
  },
  {
    icon: Calculator,
    text: "Walk me through this math problem step by step",
    category: "Math",
  },
  {
    icon: MessageSquare,
    text: "Have a thoughtful conversation about any topic",
    category: "Chat",
  },
]

const capabilities = [
  { icon: Mic, label: "Voice", description: "Natural speech" },
  { icon: Camera, label: "Vision", description: "Image analysis" },
  { icon: Radio, label: "Live", description: "Real-time" },
  { icon: Eye, label: "OCR", description: "Read docs" },
]

const stats = [
  { label: "Neural Cores", value: "128", icon: Cpu },
  { label: "Languages", value: "95+", icon: Globe },
  { label: "Encryption", value: "AES-256", icon: Shield },
]

export function WelcomeScreen({ onSuggestionClick, userName }: WelcomeScreenProps) {
  const greeting = userName && userName !== "User" ? `Hello, ${userName}` : "Welcome, Human"

  return (
    <div className="flex flex-1 flex-col items-center justify-center px-4 py-8 overflow-y-auto relative">
      <div className="flex flex-col items-center gap-6 text-center relative">
        {/* Animated logo container */}
        <div className="relative">
          {/* Outer glow ring */}
          <div className="absolute inset-0 rounded-full bg-primary/20 blur-xl scale-150" />

          {/* Logo container with border animation */}
          <div className="relative rounded-2xl p-6 glow-border bg-card/50 backdrop-blur-sm">
            <AlphaLogo className="h-20 w-20 md:h-24 md:w-24" />
          </div>

          {/* Status indicator */}
          <div className="absolute -top-1 -right-1 flex items-center gap-1.5 px-2 py-1 rounded-full bg-card border border-border">
            <span className="h-2 w-2 rounded-full bg-emerald-400 orb-glow" />
            <span className="text-[10px] font-mono text-emerald-400 uppercase tracking-wider">Online</span>
          </div>
        </div>

        {/* Title with gradient */}
        <div className="space-y-2">
          <p className="text-sm font-mono text-muted-foreground uppercase tracking-[0.3em]">Alpha AI System v2.0</p>
          <h1 className="text-3xl md:text-4xl font-bold tracking-tight text-gradient">{greeting}</h1>
          <p className="text-muted-foreground text-pretty max-w-md leading-relaxed">
            Advanced neural intelligence with voice synthesis, computer vision, and human-like reasoning capabilities.
          </p>
        </div>
      </div>

      <div className="mt-8 flex flex-wrap justify-center gap-6">
        {stats.map((stat) => (
          <div
            key={stat.label}
            className="flex items-center gap-3 px-4 py-2 rounded-lg bg-card/30 border border-border/50 backdrop-blur-sm"
          >
            <stat.icon className="h-4 w-4 text-primary glow-icon" />
            <div className="text-left">
              <p className="text-xs text-muted-foreground uppercase tracking-wider">{stat.label}</p>
              <p className="text-sm font-mono font-bold text-primary">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 flex flex-wrap justify-center gap-2">
        {capabilities.map((cap) => (
          <div
            key={cap.label}
            className="flex items-center gap-2 px-4 py-2 rounded-full bg-secondary/50 border border-primary/20 text-xs backdrop-blur-sm hover:border-primary/50 transition-colors"
          >
            <cap.icon className="h-3.5 w-3.5 text-primary" />
            <span className="font-medium">{cap.label}</span>
            <span className="text-muted-foreground hidden sm:inline">/ {cap.description}</span>
          </div>
        ))}
      </div>

      <div className="mt-10 grid w-full max-w-2xl gap-3 sm:grid-cols-2">
        {suggestions.map((suggestion) => (
          <button
            key={suggestion.text}
            onClick={() => onSuggestionClick(suggestion.text)}
            className="futuristic-card flex items-start gap-4 rounded-xl p-4 text-left group"
          >
            <div className="rounded-lg bg-primary/10 p-2.5 group-hover:bg-primary/20 transition-colors border border-primary/20">
              <suggestion.icon className="h-5 w-5 text-primary glow-icon" />
            </div>
            <div className="flex-1 min-w-0">
              <span className="text-[10px] font-mono text-primary uppercase tracking-wider">{suggestion.category}</span>
              <p className="text-sm mt-1 text-foreground/90">{suggestion.text}</p>
            </div>
          </button>
        ))}
      </div>

      <div className="mt-10 w-full max-w-2xl">
        <div className="rounded-xl bg-card/30 border border-border/50 backdrop-blur-sm overflow-hidden">
          {/* Terminal header */}
          <div className="flex items-center gap-2 px-4 py-2 bg-secondary/30 border-b border-border/50">
            <div className="flex gap-1.5">
              <span className="h-2.5 w-2.5 rounded-full bg-red-500/60" />
              <span className="h-2.5 w-2.5 rounded-full bg-yellow-500/60" />
              <span className="h-2.5 w-2.5 rounded-full bg-green-500/60" />
            </div>
            <span className="text-[10px] font-mono text-muted-foreground uppercase tracking-wider ml-2">
              System Commands
            </span>
          </div>

          {/* Terminal content */}
          <div className="p-4 font-mono text-xs space-y-2">
            <div className="flex items-start gap-2">
              <span className="text-primary">$</span>
              <span className="text-muted-foreground">
                <Mic className="h-3 w-3 inline mr-2 text-primary" />
                voice --input &quot;Speak your message naturally&quot;
              </span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-primary">$</span>
              <span className="text-muted-foreground">
                <Camera className="h-3 w-3 inline mr-2 text-primary" />
                vision --analyze &quot;Point camera at any object&quot;
              </span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-primary">$</span>
              <span className="text-muted-foreground">
                <Radio className="h-3 w-3 inline mr-2 text-primary" />
                live --mode &quot;Enable hands-free conversation&quot;
              </span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-primary">$</span>
              <span className="text-muted-foreground">
                <Sparkles className="h-3 w-3 inline mr-2 text-primary" />
                help --topic &quot;Ask anything, I&apos;m here to assist&quot;
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-8 flex flex-col items-center gap-4">
        <div className="flex items-center gap-3 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/30">
          <span className="h-2 w-2 rounded-full bg-emerald-400 orb-glow" />
          <span className="text-xs font-mono text-emerald-400 uppercase tracking-wider">Neural Network Active</span>
        </div>
        <div className="flex items-center gap-6 text-[10px] text-muted-foreground font-mono uppercase tracking-wider">
          <span className="flex items-center gap-1.5">
            <Zap className="h-3 w-3 text-primary" />
            Fast Response
          </span>
          <span className="flex items-center gap-1.5">
            <Brain className="h-3 w-3 text-primary" />
            Deep Learning
          </span>
          <span className="flex items-center gap-1.5">
            <Sparkles className="h-3 w-3 text-primary" />
            Context Aware
          </span>
        </div>
      </div>
    </div>
  )
}
