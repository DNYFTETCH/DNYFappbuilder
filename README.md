# DNYFappbuilder v2.0.0

[![Build & Test](https://github.com/DNYFTECH/DNYFappbuilder/actions/workflows/build.yml/badge.svg)](https://github.com/DNYFTECH/DNYFappbuilder/actions/workflows/build.yml)
[![Release](https://github.com/DNYFTECH/DNYFappbuilder/actions/workflows/release.yml/badge.svg)](https://github.com/DNYFTECH/DNYFappbuilder/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Termux-brightgreen)](#)
[![Made by DNYFTECH](https://img.shields.io/badge/made%20by-DNYFTECH-6C63FF)](https://github.com/DNYFTECH)

> **Production-grade multi-language build system with device installation**
>
> Build → Sign → Install → Deploy — all from one CLI, including Termux on Android

---

## Install

```bash
# One-liner (Linux / macOS / Termux)
curl -fsSL https://raw.githubusercontent.com/DNYFTECH/DNYFappbuilder/main/install.sh | bash

# Or manually
git clone https://github.com/DNYFTECH/DNYFappbuilder.git ~/dnyf-appbuilder
cd ~/dnyf-appbuilder && ./setup.sh
source ~/.bashrc
```

**Termux (Android)**
```bash
pkg install git curl
curl -fsSL https://raw.githubusercontent.com/DNYFTECH/DNYFappbuilder/main/install.sh | bash
```

After install, verify:
```bash
abp doctor
```

---

## Quick Start

```bash
abp init myapp flutter
abp build myapp --target android --profile release --sign --install
```

---

## Commands

### Project
```bash
abp init <name> <template>        # Create project
abp build <path> [options]        # Build app
abp clean                         # Clear cache
```

### Device Installation
```bash
abp devices                       # List connected devices
abp install app.apk               # Install to device
abp install app.apk --all         # Install to all devices
abp install app.apk --wireless <ip>  # WiFi install (no USB)
abp install app.apk --qr          # QR code wireless install
abp uninstall com.my.app          # Remove from device
abp screenshot                    # Capture device screen
abp logcat                        # Stream device logs
```

### Signing
```bash
abp keygen                        # Generate release keystore
abp sign app.apk --auto           # Sign APK
abp verify-sign app.apk           # Verify signature
```

### Deploy
```bash
abp deploy render                 # Deploy to Render
abp deploy railway                # Deploy to Railway
abp deploy vercel                 # Deploy to Vercel
abp deploy heroku                 # Deploy to Heroku
abp deploy docker <image>         # Push Docker image
abp deploy github-pages           # Deploy to GitHub Pages
```

### Utilities
```bash
abp doctor                        # Environment health check
abp logs                          # View build logs
abp env create production         # Manage .env profiles
abp plugins list                  # List plugins
abp update                        # Self-update
```

### Build Options
```bash
--target android|ios|web|all
--profile debug|release|staging
--parallel          # Build all targets simultaneously
--sign              # Auto-sign after build
--install           # Install to device after build
--notify            # Push notification when done
--no-cache          # Skip build cache
```

---

## Templates

| Template | Language | Output |
|---|---|---|
| `react-native` | TypeScript | Android APK / iOS IPA |
| `flutter` | Dart | Android APK / iOS / Web |
| `android` | Kotlin | Android APK |
| `nodejs` | JavaScript | Node.js server |
| `python` | Python | FastAPI server |
| `java` | Java | Spring Boot JAR |
| `react` | JavaScript | Vite web app |
| `vue` | JavaScript | Vite web app |

---

## Examples

```
examples/
├── nodejs-api/       Node.js Express API
├── python-api/       Python FastAPI
├── flutter-app/      Flutter cross-platform app
└── react-native-app/ React Native mobile app
```

---

## Requirements

| Tool | Required | Install |
|---|---|---|
| `bash` | ✅ | Pre-installed |
| `git` | ✅ | `pkg install git` |
| `node` + `npm` | For JS projects | `pkg install nodejs` |
| `python3` | For Python projects | `pkg install python` |
| `java` (JDK 17) | For Android/Java | `pkg install openjdk-17` |
| `flutter` | For Flutter | [flutter.dev](https://flutter.dev) |
| `adb` | For device install | `pkg install android-tools` |
| `docker` | For Docker builds | [docker.com](https://docker.com) |

---

## License

MIT © [DNYFTECH](https://github.com/DNYFTECH)
