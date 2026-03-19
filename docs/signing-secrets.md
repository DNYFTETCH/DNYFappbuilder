# APK Signing with GitHub Actions

DNYFappbuilder supports automatic APK signing in CI using GitHub repository secrets.

## Setup (one time)

### 1. Generate your keystore

```bash
abp keygen
```

This creates `~/dnyf-appbuilder/config/dnyf-release.keystore` and prints your secrets.

### 2. Encode keystore to base64

```bash
# Linux / Termux
base64 ~/dnyf-appbuilder/config/dnyf-release.keystore

# macOS
base64 -i ~/dnyf-appbuilder/config/dnyf-release.keystore | pbcopy
```

### 3. Add secrets to GitHub

Go to: `Settings → Secrets and variables → Actions → New repository secret`

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | base64 output from step 2 |
| `KEY_ALIAS` | `abp-key` (or your alias) |
| `KEY_PASSWORD` | your key password |
| `STORE_PASSWORD` | your keystore password |

### 4. Tag a release — CI signs automatically

```bash
git tag v2.0.1
git push origin v2.0.1
```

The release workflow will decode the keystore, sign the APK, and attach it to the GitHub Release.

## Security

- **Never commit** your `.keystore` file or `github-secrets.txt`
- Both are automatically added to `.gitignore` by `abp keygen`
- GitHub encrypts secrets at rest — they are never visible after saving
- Use separate keystores for debug and release builds
