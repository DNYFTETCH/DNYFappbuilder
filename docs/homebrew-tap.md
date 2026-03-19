# Homebrew Tap Setup

DNYFappbuilder is available via Homebrew on macOS and Linux.

## For users — install abp

```bash
brew tap DNYFTETCH/tap
brew install abp
abp doctor
```

## For maintainers — create the tap repo

The tap lives in a separate GitHub repo named exactly `homebrew-tap`.

### 1. Create the repo

```
GitHub → New repository → Name: homebrew-tap → Public → Create
```

### 2. Push the Formula

```bash
# Clone the new tap repo
git clone https://github.com/DNYFTETCH/homebrew-tap.git
cd homebrew-tap

# Copy formula from this repo
mkdir -p Formula
cp path/to/upgrade-3/homebrew-tap/Formula/abp.rb Formula/
cp path/to/upgrade-3/homebrew-tap/README.md .

git add -A
git commit -m "feat: add abp formula v2.0.0"
git push origin main
```

### 3. Add HOMEBREW_TAP_TOKEN secret

The `update-homebrew.yml` workflow auto-updates the formula on every release.
It needs a Personal Access Token with `repo` scope to push to homebrew-tap.

```
DNYFappbuilder repo → Settings → Secrets → Actions
→ New secret: HOMEBREW_TAP_TOKEN = <your PAT>
```

### 4. Update SHA256 in formula

After pushing your first release tag, get the real SHA256:

```bash
VERSION="2.0.0"
curl -sL https://github.com/DNYFTETCH/DNYFappbuilder/archive/refs/tags/v${VERSION}.tar.gz \
  | sha256sum
```

Replace `PLACEHOLDER_SHA256` in `Formula/abp.rb` with the output.

### 5. Test locally

```bash
brew tap DNYFTETCH/tap
brew install --build-from-source DNYFTETCH/tap/abp
abp doctor
```

### Auto-updates

After this setup, every time you push a new release tag (`git tag v2.0.1 && git push origin v2.0.1`), the `update-homebrew.yml` workflow automatically:

1. Downloads the new tarball
2. Computes the SHA256
3. Updates `Formula/abp.rb`
4. Commits and pushes to `homebrew-tap`

Users get the update with `brew upgrade abp`.
