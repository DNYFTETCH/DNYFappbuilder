# Device Installation Guide

DNYFappbuilder v2.0.0 supports installing your built apps directly to physical devices and emulators.

---

## Android Installation

### Prerequisites

- ADB installed: `pkg install android-tools` (Termux) | `apt install adb` (Linux)
- USB debugging enabled on device (Settings → Developer options → USB debugging)

### Check connected devices

```bash
abp devices
```

### Install to connected device

```bash
# Single device (auto-selected)
abp install myapp.apk

# Specific device
abp install myapp.apk --device DEVICE_SERIAL

# All connected devices
abp install myapp.apk --all
```

### Verify installation

```bash
abp install myapp.apk --verify --package com.mycompany.myapp
```

---

## Wireless Installation (WiFi ADB)

No USB cable needed — install over the same WiFi network.

### Step 1 — Connect USB first, enable wireless

```bash
abp devices --enable-wireless
# Follow instructions to get your device IP
```

### Step 2 — Disconnect USB, install wirelessly

```bash
abp install myapp.apk --wireless 192.168.1.10
```

### Or connect and install in one command

```bash
abp devices --connect 192.168.1.10
abp install myapp.apk --all
```

---

## QR Code Install

Serve your APK over HTTP and display a QR code. Scan with the device camera to download and install.

```bash
abp install myapp.apk --qr
```

Device requirements:
- Device must be on the same WiFi network as your machine
- Allow "Install from unknown sources" on the device (Settings → Security)
- Use a file manager / browser that supports APK install (or ADB Install via QR apps)

For Termux users:
```bash
pkg install qrencode
abp install myapp.apk --qr
```

---

## Build + Sign + Install in One Step

```bash
# Build, sign, and install immediately
abp build . --target android --profile release --sign --install

# Install to a specific device after build
abp build . --target android --sign --install --device emulator-5554
```

---

## iOS Installation

### Requirements (macOS only)
- `ios-deploy`: `npm install -g ios-deploy`
- Or: Xcode with `xcrun devicectl`

```bash
# Connect iPhone/iPad via USB
abp install myapp.ipa

# Specific device UDID
abp install myapp.ipa --device DEVICE_UDID
```

---

## Uninstalling Apps

```bash
# Uninstall from connected device
abp uninstall com.mycompany.myapp

# Uninstall from specific device
abp uninstall com.mycompany.myapp --device SERIAL

# Uninstall from all devices
abp uninstall com.mycompany.myapp --all
```

---

## Device Utilities

```bash
# Take screenshot
abp screenshot
abp screenshot --device SERIAL --output ~/Screenshots

# Stream device logs
abp logcat
abp logcat --device SERIAL
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `ADB not found` | `pkg install android-tools` |
| `unauthorized` | Accept USB debugging prompt on device |
| `device offline` | Reconnect USB / restart ADB: `adb kill-server && adb start-server` |
| `Install failed (INSTALL_FAILED_VERSION_DOWNGRADE)` | Uninstall existing app first: `abp uninstall <package>` |
| Wireless connection fails | Ensure both devices are on same WiFi; try `adb kill-server` |
| QR scan doesn't open APK | Enable "Install from unknown sources" on device |
