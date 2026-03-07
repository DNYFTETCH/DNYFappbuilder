# Changelog

## [2.0.0] — 2025-03-06

### Added — Device Installation
- `abp devices` — List all connected Android/iOS devices
- `abp devices --wireless` — Enable wireless ADB
- `abp devices --connect <ip>` — Connect to WiFi device
- `abp install <app>` — Install APK/IPA to device
- `abp install --all` — Install to all connected devices
- `abp install --wireless <ip>` — Install via WiFi ADB
- `abp install --qr` — Generate QR code for wireless install
- `abp install --verify` — Verify installation after install
- `abp uninstall <package>` — Remove app from device(s)
- `abp screenshot` — Capture device screenshot
- `abp logcat` — Stream device logs

### Added — Signing
- `abp sign <apk>` — Sign APK with keystore
- `abp keygen` — Generate release keystore
- `abp verify-sign <apk>` — Verify APK signature
- `abp build --sign` — Auto-sign after build
- `abp build --install` — Auto-install after build

### Added — Deploy
- `abp deploy render` — Deploy to Render.com
- `abp deploy railway` — Deploy to Railway.app
- `abp deploy vercel` — Deploy to Vercel
- `abp deploy heroku` — Deploy to Heroku
- `abp deploy docker <image>` — Push to Docker registry
- `abp deploy github-pages` — Deploy to GitHub Pages

### Added — Utilities
- `abp doctor` — Full environment health check
- `abp env` — Environment profile management (create/edit/apply/delete)
- `abp logs` — View build logs
- `abp update` — Self-update from GitHub
- `abp plugins` — Plugin management (list/install/remove)

### Added — Templates
- React (Vite), Vue (Vite) templates
- Full-featured nodejs template (Express + helmet + rate-limit)
- FastAPI template with proper project structure
- Native Android (Kotlin) with full Gradle setup

### Improved
- Build script: `--profile`, `--parallel`, `--no-cache`, `--notify` flags
- Docker: multi-stage builds with health checks for all images
- New Dockerfiles: Android, Flutter, Java/Spring Boot
- GitHub Actions: build, test, release workflows
- Bash & Zsh completion scripts
- Termux-optimized setup and PATH handling
- `abp version` shows all runtime info
- Colorized output with spinners and timers
- Build log file with timestamps

### Plugins
- `qr-installer` — QR code wireless APK distribution
- `gradle-optimizer` — Gradle performance flags
- `npm-security` — npm audit integration

## [1.0.0] — Initial Release

- Basic build system: React Native, Flutter, Android, Node.js, Python, Java
- `abp init`, `abp build`, `abp docker`, `abp clean`
- Docker support (Node.js, Python)
- CI/CD with GitHub Actions
- Termux compatibility
