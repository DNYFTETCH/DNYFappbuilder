# Changelog — DNYFappbuilder

## v2.2.0 — 2025

### ✨ New Templates (6 added)
- **`nextjs`** — Next.js 14 App Router with TypeScript, API routes, layout
- **`svelte`** — SvelteKit with Vite, Pinia-equivalent stores
- **`electron`** — Electron 28 desktop app with secure preload, context isolation
- **`nodejs-ts`** — Node.js + TypeScript + Express with full tsconfig
- **`django`** — Django 4.2 + Django REST Framework + CORS + WhiteNoise
- **`go`** — Go 1.21 HTTP server with Chi router, Makefile
- **`pwa`** — Progressive Web App with Vite PWA plugin, service worker, offline support
- **`rust`** — Actix-Web 4 REST API with health endpoint

### 🔧 Fixes
- **React template** — fully scaffolded without `npm create vite@latest` (no internet required, no prompts)
- **Vue template** — fully scaffolded without `npm create vite@latest`, includes Pinia + Vue Router
- **Android template** — migrated to Kotlin DSL (`build.gradle.kts`), ViewBinding enabled
- **Python template** — added SQLAlchemy, Alembic, pytest-asyncio, full test suite

### ⚡ Build Engine
- **`build.sh`** — added dispatch for: `react`, `vue`, `svelte`, `pwa` (Vite), `nextjs`, `electron`, `golang`, `rust`, `django`
- Vite builds respect `--profile` via `--mode production/development`
- Go: compiles to binary in `BUILD_DIR`
- Rust: `cargo build --release` dispatched correctly

### 🔍 Detection (detect.sh)
- New types detected: `svelte`, `electron`, `nextjs`, `react`, `vue` (via vite.config), `nodejs-ts`, `django`, `golang`, `rust`, `pwa`
- React vs Vue distinguished via vite.config + package.json deps
- TypeScript Node projects detected separately

### 🧪 Tests
- 8 new test files added (init-react, init-vue, init-python, init-go, init-electron, init-nextjs, build-python, build-react)
- `test-detect.sh` — validates all 8 project type detections
- `run-tests.sh` — expanded to 18 total test slots

### 🩺 Doctor
- `abp doctor --fix` — auto-installs missing tools via pkg/apt/brew/dnf/pacman
- Detects package manager automatically
- Saves re-run after fix

### 🔐 Signing Secrets
- `abp keygen` — prints all 4 GitHub Actions secret values
- Saves secrets to `config/github-secrets.txt` (auto-gitignored)
- Release workflow decodes `KEYSTORE_BASE64` for CI signing

### 🍺 Homebrew
- `brew tap DNYFTETCH/tap && brew install abp` now available
- `update-homebrew.yml` auto-updates formula on release tags

---

## v2.0.0 — 2025

### ✨ New Features
- Device install engine (USB · WiFi ADB · QR code)
- APK signing pipeline (`abp keygen`, `abp sign`, `abp verify-sign`)
- 6 cloud deploy targets (Render · Railway · Vercel · Heroku · Docker · GitHub Pages)
- Plugin system (qr-installer · gradle-optimizer · npm-security)
- `abp doctor` environment diagnostics
- `abp env` profile manager
- `abp update` self-updater
- Bash + Zsh tab completion
- GitHub Actions CI (6 jobs)
- Kubernetes manifests
- Docker multi-stage builds (5 Dockerfiles)

### 🔧 Renamed
- AppBuilder Pro → **DNYFappbuilder**
- `appbuilder-pro` → `dnyf-appbuilder`

---

## v1.0.0 — 2024

- Initial release — core build system
- Commands: init, build, docker, clean, version
- Templates: react-native, flutter, android, nodejs, python, java, react, vue
- Node.js + Python Docker templates
