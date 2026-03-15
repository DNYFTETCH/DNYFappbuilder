"use client"

import { useEffect, useState } from "react"

export function AlphaLogo({ className = "", animated = true }: { className?: string; animated?: boolean }) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <defs>
        {/* Holographic gradient */}
        <linearGradient id="holoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#00d4ff">
            {mounted && animated && (
              <animate attributeName="stop-color" values="#00d4ff;#a855f7;#00d4ff" dur="4s" repeatCount="indefinite" />
            )}
          </stop>
          <stop offset="50%" stopColor="#06b6d4" />
          <stop offset="100%" stopColor="#a855f7">
            {mounted && animated && (
              <animate attributeName="stop-color" values="#a855f7;#00d4ff;#a855f7" dur="4s" repeatCount="indefinite" />
            )}
          </stop>
        </linearGradient>

        {/* Glow filter */}
        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="2" result="coloredBlur" />
          <feMerge>
            <feMergeNode in="coloredBlur" />
            <feMergeNode in="coloredBlur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>

        {/* Inner glow */}
        <filter id="innerGlow">
          <feGaussianBlur stdDeviation="1.5" result="blur" />
          <feComposite in="SourceGraphic" in2="blur" operator="over" />
        </filter>

        {/* Radial gradient for core */}
        <radialGradient id="coreGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#00d4ff" stopOpacity="1" />
          <stop offset="70%" stopColor="#00d4ff" stopOpacity="0.3" />
          <stop offset="100%" stopColor="#00d4ff" stopOpacity="0" />
        </radialGradient>
      </defs>

      {/* Outer ring with rotation */}
      <g filter="url(#glow)">
        <circle
          cx="24"
          cy="24"
          r="22"
          stroke="url(#holoGradient)"
          strokeWidth="1"
          fill="none"
          strokeDasharray="4 4"
          opacity="0.5"
        >
          {mounted && animated && (
            <animateTransform
              attributeName="transform"
              type="rotate"
              from="0 24 24"
              to="360 24 24"
              dur="20s"
              repeatCount="indefinite"
            />
          )}
        </circle>
      </g>

      {/* Middle ring */}
      <circle
        cx="24"
        cy="24"
        r="18"
        stroke="url(#holoGradient)"
        strokeWidth="1.5"
        fill="none"
        opacity="0.7"
        filter="url(#glow)"
      />

      {/* Inner hexagonal shape */}
      <path
        d="M24 6L38 15V33L24 42L10 33V15L24 6Z"
        stroke="url(#holoGradient)"
        strokeWidth="1.5"
        fill="none"
        opacity="0.8"
        filter="url(#glow)"
      />

      {/* Core glow */}
      <circle cx="24" cy="24" r="8" fill="url(#coreGlow)" opacity="0.6">
        {mounted && animated && <animate attributeName="r" values="6;8;6" dur="2s" repeatCount="indefinite" />}
      </circle>

      {/* Alpha symbol - redesigned */}
      <path d="M24 14L30 30H27L25.5 26H22.5L21 30H18L24 14Z" fill="url(#holoGradient)" filter="url(#glow)" />
      <circle cx="24" cy="20" r="1.5" fill="#0a0a0f" />

      {/* Neural connection points */}
      <g className="neural-dots">
        <circle cx="24" cy="6" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" />
          )}
        </circle>
        <circle cx="38" cy="15" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" begin="0.3s" />
          )}
        </circle>
        <circle cx="38" cy="33" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" begin="0.6s" />
          )}
        </circle>
        <circle cx="24" cy="42" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" begin="0.9s" />
          )}
        </circle>
        <circle cx="10" cy="33" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" begin="1.2s" />
          )}
        </circle>
        <circle cx="10" cy="15" r="2" fill="url(#holoGradient)" className="neural-dot" filter="url(#glow)">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" begin="1.5s" />
          )}
        </circle>
      </g>

      {/* Data flow lines */}
      <g stroke="url(#holoGradient)" strokeWidth="1" opacity="0.5">
        <line x1="24" y1="8" x2="24" y2="12">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" />
          )}
        </line>
        <line x1="36" y1="16" x2="32" y2="18">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" begin="0.25s" />
          )}
        </line>
        <line x1="36" y1="32" x2="32" y2="30">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" begin="0.5s" />
          )}
        </line>
        <line x1="24" y1="40" x2="24" y2="36">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" begin="0.75s" />
          )}
        </line>
        <line x1="12" y1="32" x2="16" y2="30">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" begin="1s" />
          )}
        </line>
        <line x1="12" y1="16" x2="16" y2="18">
          {mounted && animated && (
            <animate attributeName="opacity" values="0.2;0.8;0.2" dur="1.5s" repeatCount="indefinite" begin="1.25s" />
          )}
        </line>
      </g>
    </svg>
  )
}
