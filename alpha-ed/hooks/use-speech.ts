"use client"

import { useState, useEffect, useCallback, useRef } from "react"
import type { UserSettings } from "@/lib/types"
import type { SpeechRecognition } from "web-speech-api"

interface UseSpeechOptions {
  settings: UserSettings | null
  onTranscript?: (text: string, isFinal: boolean) => void
  onSpeakEnd?: () => void
}

export function useSpeech({ settings, onTranscript, onSpeakEnd }: UseSpeechOptions) {
  const [isListening, setIsListening] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [voices, setVoices] = useState<SpeechSynthesisVoice[]>([])
  const [isSupported, setIsSupported] = useState({ stt: false, tts: false })
  const recognitionRef = useRef<SpeechRecognition | null>(null)
  const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null)

  // Check browser support
  useEffect(() => {
    const sttSupported = "SpeechRecognition" in window || "webkitSpeechRecognition" in window
    const ttsSupported = "speechSynthesis" in window
    setIsSupported({ stt: sttSupported, tts: ttsSupported })

    // Load voices
    if (ttsSupported) {
      const loadVoices = () => {
        const availableVoices = speechSynthesis.getVoices()
        // Prefer natural/premium voices
        const sortedVoices = availableVoices.sort((a, b) => {
          const aScore = a.name.includes("Natural") || a.name.includes("Premium") ? 1 : 0
          const bScore = b.name.includes("Natural") || b.name.includes("Premium") ? 1 : 0
          return bScore - aScore
        })
        setVoices(sortedVoices)
      }
      loadVoices()
      speechSynthesis.addEventListener("voiceschanged", loadVoices)
      return () => speechSynthesis.removeEventListener("voiceschanged", loadVoices)
    }
  }, [])

  // Initialize speech recognition
  useEffect(() => {
    if (!isSupported.stt) return

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    const recognition = new SpeechRecognition()
    recognition.continuous = true
    recognition.interimResults = true
    recognition.lang = "en-US"

    recognition.onresult = (event) => {
      const lastResult = event.results[event.results.length - 1]
      const transcript = lastResult[0].transcript
      const isFinal = lastResult.isFinal
      onTranscript?.(transcript, isFinal)
    }

    recognition.onerror = (event) => {
      console.error("Speech recognition error:", event.error)
      setIsListening(false)
    }

    recognition.onend = () => {
      setIsListening(false)
    }

    recognitionRef.current = recognition

    return () => {
      recognition.stop()
    }
  }, [isSupported.stt, onTranscript])

  const startListening = useCallback(() => {
    if (!recognitionRef.current || isListening) return
    try {
      recognitionRef.current.start()
      setIsListening(true)
    } catch (error) {
      console.error("Failed to start listening:", error)
    }
  }, [isListening])

  const stopListening = useCallback(() => {
    if (!recognitionRef.current) return
    recognitionRef.current.stop()
    setIsListening(false)
  }, [])

  const speak = useCallback(
    (text: string) => {
      if (!isSupported.tts || !settings?.voiceEnabled) return

      // Cancel any ongoing speech
      speechSynthesis.cancel()

      const utterance = new SpeechSynthesisUtterance(text)
      utterance.rate = settings.voiceSpeed
      utterance.pitch = settings.voicePitch

      // Find selected voice or use default
      if (settings.selectedVoice && voices.length > 0) {
        const voice = voices.find((v) => v.name === settings.selectedVoice)
        if (voice) utterance.voice = voice
      } else if (voices.length > 0) {
        // Default to first natural-sounding voice
        utterance.voice = voices[0]
      }

      utterance.onstart = () => setIsSpeaking(true)
      utterance.onend = () => {
        setIsSpeaking(false)
        onSpeakEnd?.()
      }
      utterance.onerror = () => setIsSpeaking(false)

      utteranceRef.current = utterance
      speechSynthesis.speak(utterance)
    },
    [isSupported.tts, settings, voices, onSpeakEnd],
  )

  const stopSpeaking = useCallback(() => {
    speechSynthesis.cancel()
    setIsSpeaking(false)
  }, [])

  return {
    isListening,
    isSpeaking,
    voices,
    isSupported,
    startListening,
    stopListening,
    speak,
    stopSpeaking,
  }
}

// TypeScript declarations for Web Speech API
declare global {
  interface Window {
    SpeechRecognition: typeof SpeechRecognition
    webkitSpeechRecognition: typeof SpeechRecognition
  }
}
