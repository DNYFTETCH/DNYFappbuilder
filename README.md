# DNYFappbuilder v2.0.0

> **Production-grade multi-language build system with device installation**
>
> Build → Sign → Install → Deploy — all from one CLI

[![Build](https://github.com/DNYFTECH/dnyf-appbuilder/actions/workflows/build.yml/badge.svg)](https://github.com/DNYFTECH/dnyf-appbuilder/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What's New in v2.0.0

- **Device Installation** — Install APKs/IPAs directly to connected devices
- **Wireless Install** — Install via WiFi ADB (no USB required)
- **QR Code Install** — Serve APK as QR code for instant device install
- **Multi-Device** — Install to all connected devices in one command
- **APK Signing** — Built-in keystore management and APK signing
- **Doctor command** — Full environment health check
- **Deploy to Render, Railway, Vercel, Heroku, Docker**
- **Environment profiles** — Manage dev/staging/production `.env` files
- **Termux optimized** — Full support for Termux on Android
- **Self-update** — `abp update` pulls latest version from GitHub

---

## Quick Install

```bash
git clone https://github.com/DNYFTECH/dnyf-appbuilder.git
cd dnyf-appbuilder
chmod +x setup.sh && ./setup.sh
source ~/.bashrc
abp doctor
```

---

## Usage

### Create a Project
```bash
abp init myapp react-native
abp init myapp flutter
abp init myapp nodejs
abp init myapp python
abp init myapp android
```

### Build
```bash
abp build .                                       # Auto-detect, default target
abp build . --target android                      # Android APK
abp build . --target android --profile release    # Release build
abp build . --target all --parallel               # All targets, parallel
abp build . --target android --sign --install     # Build + sign + install
abp build . --notify                              # Notify when done
```

### Device Management
```bash
abp devices                    # List all connected devices
abp devices --wireless         # Enable wireless ADB
abp devices --connect 192.168.1.10  # Connect to WiFi device
```

### Install Apps on Devices
```bash
abp install app.apk                          # Auto-select device
abp install app.apk --all                   # All connected devices
abp install app.apk --device emulator-5554  # Specific device
abp install app.apk --wireless 192.168.1.10 # Via WiFi ADB
abp install app.apk --qr                    # QR code (scan on device)
abp install app.apk --verify --package com.myapp  # Verify after install
```

### APK Signing
```bash
abp keygen                          # Generate release keystore
abp sign app.apk --auto             # Auto-sign (generates keystore if needed)
abp sign app.apk --keystore my.jks --alias mykey
abp verify-sign app.apk             # Verify signature
```

### Deploy
```bash
abp deploy render
abp deploy railway
abp deploy vercel
abp deploy heroku
abp deploy docker ghcr.io/dnyftech/myapp:latest
abp deploy github-pages
```

### Utilities
```bash
abp doctor                    # Environment health check
abp logs                      # View build logs
abp logs --tail 100           # Last 100 lines
abp env create production     # Create env profile
abp env apply production      # Apply to current dir
abp plugins list              # List installed plugins
abp update                    # Self-update
abp screenshot                # Screenshot from device
abp logcat                    # Stream device logs
abp uninstall com.my.app      # Uninstall from device
```

---

## Supported Templates

| Template | Language | Targets |
|---|---|---|
| `react-native` | JavaScript/TypeScript | Android, iOS |
| `flutter` | Dart | Android, iOS, Web |
| `android` | Kotlin | Android |
| `nodejs` | JavaScript | Server |
| `python` | Python (FastAPI) | Server |
| `java` | Java (Spring Boot) | Server |
| `react` | JavaScript (Vite) | Web |
| `vue` | JavaScript (Vite) | Web |

---

## Termux Setup

```bash
# Install required tools
pkg update
pkg install android-tools git nodejs python openjdk-17 qrencode

# Install DNYFappbuilder
git clone https://github.com/DNYFTECH/dnyf-appbuilder.git
cd dnyf-appbuilder && ./setup.sh
source ~/.bashrc

# Connect device and install
abp devices
abp install myapp.apk --all
```

---

## Plugins

| Plugin | Description |
|---|---|
| `gradle-optimizer` | Injects Gradle performance optimizations |
| `npm-security` | npm audit and auto-fix |
| `qr-installer` | QR code wireless APK distribution |

---

## Documentation

- [Installation Guide](docs/installation.md)
- [Quickstart](docs/quickstart.md)
- [Device Installation Guide](docs/device-install.md)
- [FAQ](docs/faq.md)

---

## License

MIT © [DNYFTECH](https://github.com/DNYFTECH)
