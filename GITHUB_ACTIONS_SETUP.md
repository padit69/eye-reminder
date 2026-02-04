# GitHub Actions CI/CD Setup for Eye Reminder

This document explains how to set up automatic builds and releases for the Eye Reminder macOS app using GitHub Actions.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [GitHub Actions Workflows](#github-actions-workflows)
4. [Setting Up Secrets](#setting-up-secrets)
5. [Creating Releases](#creating-releases)
6. [Code Signing and Notarization](#code-signing-and-notarization)
7. [Troubleshooting](#troubleshooting)

---

## Overview

This CI/CD setup will:
- ✅ Automatically build your app on every push to `main` branch
- ✅ Run builds on pull requests
- ✅ Create automatic releases when you push a git tag (e.g., `v1.0.0`)
- ✅ Generate `.app` bundles and `.dmg` installers
- ✅ Attach built artifacts to GitHub releases
- ✅ (Optional) Code sign and notarize the app for distribution

---

## Prerequisites

Before setting up GitHub Actions, ensure you have:

1. **GitHub Repository**: Your project is hosted on GitHub
2. **macOS Project**: Xcode project is properly configured
3. **Git Tags**: Understanding of semantic versioning (v1.0.0, v1.1.0, etc.)
4. **Apple Developer Account** (Optional - for code signing):
   - Developer certificate
   - Provisioning profile
   - App-specific password for notarization

---

## GitHub Actions Workflows

### Workflow Structure

Create the following directory structure in your repository:

```
.github/
└── workflows/
    ├── build.yml           # Build on every push
    ├── release.yml         # Build and release on tags
    └── pr-check.yml        # Validation for pull requests
```

### 1. Continuous Integration (build.yml)

This workflow builds the app on every push to ensure code quality.

**File: `.github/workflows/build.yml`**

```yaml
name: Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    name: Build macOS App
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
      
      - name: Show Xcode version
        run: xcodebuild -version
      
      - name: Build app
        run: |
          cd EyeReminder
          xcodebuild \
            -project EyeReminder.xcodeproj \
            -scheme EyeReminder \
            -configuration Release \
            -derivedDataPath ./build \
            build
      
      - name: Check build output
        run: |
          echo "Build completed successfully!"
          ls -la EyeReminder/build/Build/Products/Release/
```

### 2. Automatic Release (release.yml)

This workflow creates releases when you push a version tag.

**File: `.github/workflows/release.yml`**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'  # Triggers on tags like v1.0.0, v1.2.3, etc.

jobs:
  release:
    name: Build and Release
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Get version from tag
        id: get_version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
      
      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
      
      - name: Build app
        run: |
          cd EyeReminder
          xcodebuild \
            -project EyeReminder.xcodeproj \
            -scheme EyeReminder \
            -configuration Release \
            -derivedDataPath ./build \
            clean build
      
      - name: Package app
        run: |
          cd EyeReminder/build/Build/Products/Release
          
          # Create a clean directory for the app
          mkdir -p EyeReminder-${{ steps.get_version.outputs.VERSION }}
          cp -R EyeReminder.app EyeReminder-${{ steps.get_version.outputs.VERSION }}/
          
          # Create ZIP archive
          zip -r -y EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip EyeReminder-${{ steps.get_version.outputs.VERSION }}
          
          # Move to artifacts directory
          mkdir -p ../../../../artifacts
          mv EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip ../../../../artifacts/
      
      - name: Create DMG (Optional)
        run: |
          cd EyeReminder/build/Build/Products/Release
          
          # Create DMG using hdiutil
          hdiutil create -volname "Eye Reminder" \
            -srcfolder EyeReminder.app \
            -ov -format UDZO \
            EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg
          
          mv EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg ../../../../artifacts/
      
      - name: Generate release notes
        id: release_notes
        run: |
          echo "NOTES<<EOF" >> $GITHUB_OUTPUT
          echo "## Eye Reminder ${{ steps.get_version.outputs.VERSION }}" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "### What's New" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "- Automated release build" >> $GITHUB_OUTPUT
          echo "- Built with Xcode $(xcodebuild -version | head -n1)" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "### Installation" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "1. Download \`EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip\` or \`.dmg\`" >> $GITHUB_OUTPUT
          echo "2. Extract and move to Applications folder" >> $GITHUB_OUTPUT
          echo "3. Launch Eye Reminder from Applications" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "### System Requirements" >> $GITHUB_OUTPUT
          echo "" >> $GITHUB_OUTPUT
          echo "- macOS 13.0 or later" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          name: Eye Reminder ${{ steps.get_version.outputs.VERSION }}
          body: ${{ steps.release_notes.outputs.NOTES }}
          draft: false
          prerelease: false
          files: |
            EyeReminder/artifacts/EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip
            EyeReminder/artifacts/EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 3. Pull Request Checks (pr-check.yml)

This workflow validates pull requests before merging.

**File: `.github/workflows/pr-check.yml`**

```yaml
name: PR Check

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    name: Validate PR
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
      
      - name: Build check
        run: |
          cd EyeReminder
          xcodebuild \
            -project EyeReminder.xcodeproj \
            -scheme EyeReminder \
            -configuration Debug \
            -derivedDataPath ./build \
            build
      
      - name: Comment on PR
        uses: actions/github-script@v7
        if: success()
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '✅ Build successful! Ready for review.'
            })
```

---

## Setting Up Secrets

For code signing and notarization, you need to add secrets to your GitHub repository.

### Adding Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Required Secrets (for signed builds)

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `CERTIFICATE_P12` | Base64-encoded Developer Certificate | Export from Keychain, convert to base64 |
| `CERTIFICATE_PASSWORD` | Password for P12 certificate | Set when exporting |
| `KEYCHAIN_PASSWORD` | Temporary keychain password | Any secure random string |
| `APPLE_ID` | Your Apple ID email | Your developer account email |
| `APPLE_ID_PASSWORD` | App-specific password | Generate in Apple ID settings |
| `APPLE_TEAM_ID` | Your Team ID | Found in Apple Developer portal |

### Exporting Certificate as Base64

```bash
# Export certificate from Keychain as .p12 file
# Then convert to base64:
base64 -i certificate.p12 -o certificate-base64.txt

# Copy the contents of certificate-base64.txt to GitHub secret
```

---

## Creating Releases

### Step-by-Step Release Process

#### 1. Update Version Number

Update version in Xcode:
- Open `EyeReminder.xcodeproj`
- Select target → General → Version
- Update version (e.g., `1.0.0`)
- Update build number (e.g., `1`)

#### 2. Commit Changes

```bash
git add .
git commit -m "Bump version to 1.0.0"
git push origin main
```

#### 3. Create and Push Tag

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to trigger release workflow
git push origin v1.0.0
```

#### 4. Monitor Release

1. Go to **Actions** tab in GitHub
2. Watch the **Release** workflow
3. Once complete, check **Releases** tab
4. Download and test the built app

### Release Naming Convention

Use semantic versioning:
- `v1.0.0` - Major release
- `v1.1.0` - Minor release (new features)
- `v1.0.1` - Patch release (bug fixes)
- `v2.0.0-beta.1` - Pre-release versions

---

## Code Signing and Notarization

For distribution outside the Mac App Store, you should sign and notarize your app.

### Enhanced Release with Code Signing

**File: `.github/workflows/release-signed.yml`**

```yaml
name: Release (Signed)

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    name: Build, Sign, and Release
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Get version
        id: get_version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
      
      - name: Import Certificate
        env:
          CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}
          CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          # Create keychain
          security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security set-keychain-settings -t 3600 -u build.keychain
          
          # Import certificate
          echo "$CERTIFICATE_P12" | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain
          
          # Cleanup
          rm certificate.p12
      
      - name: Build and Sign
        run: |
          cd EyeReminder
          xcodebuild \
            -project EyeReminder.xcodeproj \
            -scheme EyeReminder \
            -configuration Release \
            -derivedDataPath ./build \
            CODE_SIGN_IDENTITY="Developer ID Application" \
            clean build
      
      - name: Notarize App
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: |
          cd EyeReminder/build/Build/Products/Release
          
          # Create ZIP for notarization
          ditto -c -k --keepParent EyeReminder.app EyeReminder.zip
          
          # Submit for notarization
          xcrun notarytool submit EyeReminder.zip \
            --apple-id "$APPLE_ID" \
            --password "$APPLE_ID_PASSWORD" \
            --team-id "$APPLE_TEAM_ID" \
            --wait
          
          # Staple the notarization ticket
          xcrun stapler staple EyeReminder.app
      
      - name: Create Release Artifacts
        run: |
          cd EyeReminder/build/Build/Products/Release
          
          # Create final ZIP
          ditto -c -k --keepParent EyeReminder.app EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip
          
          # Create DMG
          hdiutil create -volname "Eye Reminder" \
            -srcfolder EyeReminder.app \
            -ov -format UDZO \
            EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg
          
          mkdir -p ../../../../artifacts
          mv EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip ../../../../artifacts/
          mv EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg ../../../../artifacts/
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            EyeReminder/artifacts/EyeReminder-${{ steps.get_version.outputs.VERSION }}.zip
            EyeReminder/artifacts/EyeReminder-${{ steps.get_version.outputs.VERSION }}.dmg
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Troubleshooting

### Common Issues

#### 1. Build Fails - "No such module"

**Solution**: Ensure all dependencies are properly configured in your Xcode project.

```yaml
# Add dependency resolution step
- name: Resolve dependencies
  run: |
    cd EyeReminder
    xcodebuild -resolvePackageDependencies
```

#### 2. Wrong Xcode Version

**Solution**: Specify exact Xcode version.

```yaml
- name: Select Xcode
  run: sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
```

Check available versions:
```bash
ls /Applications/ | grep Xcode
```

#### 3. Signing Fails

**Solution**: 
- Verify certificate is valid
- Check team ID matches
- Ensure certificate has proper permissions

```yaml
# List available signing identities
- name: List signing identities
  run: security find-identity -v -p codesigning
```

#### 4. Notarization Times Out

**Solution**: Increase timeout or check status manually.

```yaml
# Add timeout
xcrun notarytool submit ... --wait --timeout 30m
```

#### 5. Release Already Exists

**Solution**: Delete the existing release or use a different tag.

```bash
# Delete tag locally and remotely
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

### Debugging Workflows

Enable debug logging:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

View logs:
1. Go to **Actions** tab
2. Click on failed workflow
3. Expand steps to see detailed logs

---

## Best Practices

### 1. Semantic Versioning

Follow semantic versioning (semver):
- **Major** (v2.0.0): Breaking changes
- **Minor** (v1.1.0): New features, backward compatible
- **Patch** (v1.0.1): Bug fixes

### 2. Changelog

Maintain a `CHANGELOG.md` file:

```markdown
# Changelog

## [1.1.0] - 2024-02-04
### Added
- New feature X
- Support for Y

### Fixed
- Bug in Z

## [1.0.0] - 2024-02-01
### Added
- Initial release
```

### 3. Testing Before Release

```bash
# Test locally before pushing tag
cd EyeReminder
xcodebuild -project EyeReminder.xcodeproj \
  -scheme EyeReminder \
  -configuration Release \
  clean build
```

### 4. Draft Releases

Create draft releases for review:

```yaml
- name: Create GitHub Release
  uses: softprops/action-gh-release@v1
  with:
    draft: true  # Create as draft
    prerelease: false
```

### 5. Pre-release Versions

For beta/alpha releases:

```bash
git tag -a v1.1.0-beta.1 -m "Beta release"
git push origin v1.1.0-beta.1
```

```yaml
- name: Check if prerelease
  id: is_prerelease
  run: |
    if [[ "${{ steps.get_version.outputs.VERSION }}" =~ (alpha|beta|rc) ]]; then
      echo "PRERELEASE=true" >> $GITHUB_OUTPUT
    else
      echo "PRERELEASE=false" >> $GITHUB_OUTPUT
    fi

- name: Create Release
  with:
    prerelease: ${{ steps.is_prerelease.outputs.PRERELEASE }}
```

---

## Quick Start Commands

### Initial Setup

```bash
# Create GitHub Actions directory
mkdir -p .github/workflows

# Copy workflow files (after creating them)
# Commit and push
git add .github/
git commit -m "Add GitHub Actions workflows"
git push origin main
```

### Creating a Release

```bash
# 1. Update version in Xcode (if needed)

# 2. Commit all changes
git add .
git commit -m "Prepare for release v1.0.0"
git push origin main

# 3. Create and push tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 4. Monitor at: https://github.com/YOUR_USERNAME/eye-reminder/actions
```

### Deleting a Release

```bash
# Delete tag
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Then delete release from GitHub UI
```

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Semantic Versioning](https://semver.org/)

---

## Support

If you encounter issues with the CI/CD setup:

1. Check the Actions logs in GitHub
2. Verify Xcode project builds locally
3. Ensure all secrets are properly configured
4. Review this documentation for troubleshooting steps

---

**Happy releasing! 🚀**
