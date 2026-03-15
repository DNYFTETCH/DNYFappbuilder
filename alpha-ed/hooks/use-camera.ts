"use client"

import { useState, useRef, useCallback, useEffect } from "react"

interface UseCameraOptions {
  onCapture?: (imageData: string) => void
}

export function useCamera({ onCapture }: UseCameraOptions = {}) {
  const [isOpen, setIsOpen] = useState(false)
  const [stream, setStream] = useState<MediaStream | null>(null)
  const [facingMode, setFacingMode] = useState<"user" | "environment">("environment")
  const [error, setError] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(false)
  const videoRef = useRef<HTMLVideoElement | null>(null)
  const canvasRef = useRef<HTMLCanvasElement | null>(null)

  useEffect(() => {
    setIsSupported("mediaDevices" in navigator && "getUserMedia" in navigator.mediaDevices)
  }, [])

  const openCamera = useCallback(async () => {
    if (!isSupported) {
      setError("Camera not supported on this device")
      return
    }

    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode,
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
        audio: false,
      })
      setStream(mediaStream)
      setIsOpen(true)
      setError(null)
    } catch (err) {
      setError("Unable to access camera. Please grant permission.")
      console.error("Camera access error:", err)
    }
  }, [facingMode, isSupported])

  const closeCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach((track) => track.stop())
      setStream(null)
    }
    setIsOpen(false)
  }, [stream])

  const switchCamera = useCallback(() => {
    closeCamera()
    setFacingMode((prev) => (prev === "user" ? "environment" : "user"))
  }, [closeCamera])

  // Reopen camera when facing mode changes
  useEffect(() => {
    if (isOpen && !stream) {
      openCamera()
    }
  }, [facingMode, isOpen, stream, openCamera])

  const capturePhoto = useCallback((): string | null => {
    if (!videoRef.current || !canvasRef.current) return null

    const video = videoRef.current
    const canvas = canvasRef.current
    const context = canvas.getContext("2d")

    if (!context) return null

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    context.drawImage(video, 0, 0)

    const imageData = canvas.toDataURL("image/jpeg", 0.8)
    onCapture?.(imageData)
    return imageData
  }, [onCapture])

  return {
    isOpen,
    stream,
    error,
    isSupported,
    facingMode,
    videoRef,
    canvasRef,
    openCamera,
    closeCamera,
    switchCamera,
    capturePhoto,
  }
}
