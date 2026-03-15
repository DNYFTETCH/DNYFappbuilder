"use client"

export function FuturisticBackground() {
  return (
    <div className="fixed inset-0 pointer-events-none overflow-hidden z-0">
      {/* Grid pattern */}
      <div className="absolute inset-0 futuristic-grid opacity-30" />

      {/* Scan line effect */}
      <div className="scan-line" />

      {/* Ambient glow orbs */}
      <div
        className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full opacity-20"
        style={{
          background: "radial-gradient(circle, var(--glow-primary) 0%, transparent 70%)",
          filter: "blur(60px)",
        }}
      />
      <div
        className="absolute bottom-1/4 right-1/4 w-80 h-80 rounded-full opacity-15"
        style={{
          background: "radial-gradient(circle, var(--glow-accent) 0%, transparent 70%)",
          filter: "blur(50px)",
        }}
      />

      {/* Corner decorations */}
      <svg className="absolute top-4 left-4 w-16 h-16 text-primary opacity-20" viewBox="0 0 64 64">
        <path d="M0 20 L0 0 L20 0" fill="none" stroke="currentColor" strokeWidth="2" />
        <circle cx="0" cy="0" r="3" fill="currentColor" />
      </svg>
      <svg className="absolute top-4 right-4 w-16 h-16 text-primary opacity-20" viewBox="0 0 64 64">
        <path d="M44 0 L64 0 L64 20" fill="none" stroke="currentColor" strokeWidth="2" />
        <circle cx="64" cy="0" r="3" fill="currentColor" />
      </svg>
      <svg className="absolute bottom-4 left-4 w-16 h-16 text-primary opacity-20" viewBox="0 0 64 64">
        <path d="M0 44 L0 64 L20 64" fill="none" stroke="currentColor" strokeWidth="2" />
        <circle cx="0" cy="64" r="3" fill="currentColor" />
      </svg>
      <svg className="absolute bottom-4 right-4 w-16 h-16 text-primary opacity-20" viewBox="0 0 64 64">
        <path d="M44 64 L64 64 L64 44" fill="none" stroke="currentColor" strokeWidth="2" />
        <circle cx="64" cy="64" r="3" fill="currentColor" />
      </svg>
    </div>
  )
}
