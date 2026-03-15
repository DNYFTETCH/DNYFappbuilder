import type React from "react"
import type { Metadata, Viewport } from "next"
import { Geist, Geist_Mono } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import "./globals.css"

const _geist = Geist({ subsets: ["latin"] })
const _geistMono = Geist_Mono({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Alpha AI - Intelligent Assistant",
  description:
    "Your intelligent AI companion with voice recognition, camera vision, and human-like communication. Features speech-to-text, text-to-speech, object recognition, and live conversation mode.",
  keywords: [
    "AI assistant",
    "voice AI",
    "vision AI",
    "chatbot",
    "speech recognition",
    "text to speech",
    "open source AI",
    "PWA",
  ],
  authors: [{ name: "Alpha AI" }],
  generator: "Alpha AI",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "Alpha AI",
  },
  formatDetection: {
    telephone: false,
  },
  openGraph: {
    type: "website",
    title: "Alpha AI - Intelligent Assistant",
    description: "Your intelligent AI companion with voice, vision, and human-like communication",
    siteName: "Alpha AI",
  },
  twitter: {
    card: "summary_large_image",
    title: "Alpha AI - Intelligent Assistant",
    description: "Your intelligent AI companion with voice, vision, and human-like communication",
  },
  icons: {
    icon: [
      { url: "/icon-192.jpg", sizes: "192x192", type: "image/png" },
      { url: "/icon-512.jpg", sizes: "512x512", type: "image/png" },
    ],
    apple: "/icon-192.jpg",
  },
}

export const viewport: Viewport = {
  themeColor: "#0a1628",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: "cover",
  colorScheme: "dark",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" className="dark">
      <head>
        <link rel="apple-touch-icon" href="/icon-192.jpg" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="mobile-web-app-capable" content="yes" />
      </head>
      <body className="font-sans antialiased">
        {children}
        <Analytics />
      </body>
    </html>
  )
}
