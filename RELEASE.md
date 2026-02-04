# Release Process - Quick Guide

This is a quick reference guide for creating releases of the Eye Reminder app.

## Prerequisites

✅ Make sure you have:
- All changes committed to the `main` branch
- GitHub repository is set up with Actions enabled
- Workflows are in `.github/workflows/` directory

## Creating a New Release

### Step 1: Update Version (Optional)

If you want to update the version in Xcode:

1. Open `EyeReminder/EyeReminder.xcodeproj` in Xcode
2. Select the EyeReminder target
3. Go to General tab
4. Update **Version** (e.g., `1.0.0`) and **Build** number

### Step 2: Commit All Changes

```bash
cd /Users/dungne/SourceCode/eye-reminder

# Check status
git status

# Add all changes
git add .

# Commit with message
git commit -m "Prepare for release v1.0.0"

# Push to GitHub
git push origin main
```

### Step 3: Create and Push Tag

```bash
# Create an annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0 - Initial public release"

# Push the tag to GitHub (this triggers the release workflow)
git push origin v1.0.0
```

### Step 4: Monitor the Release

1. Go to: https://github.com/YOUR_USERNAME/eye-reminder/actions
2. Watch the "Release" workflow run
3. Wait for it to complete (usually 5-10 minutes)

### Step 5: Verify Release

1. Go to: https://github.com/YOUR_USERNAME/eye-reminder/releases
2. You should see your new release
3. Download and test the `.dmg` or `.zip` file

## Release Workflow Summary

```
git commit → git tag v1.0.0 → git push origin v1.0.0 → GitHub Actions builds → Release created
```

## Version Naming

Use semantic versioning (SemVer):

- `v1.0.0` - Major release (breaking changes)
- `v1.1.0` - Minor release (new features)
- `v1.0.1` - Patch release (bug fixes)
- `v2.0.0-beta.1` - Beta/pre-release

## Undoing a Release

If you need to delete a release:

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Then manually delete the release from GitHub UI:
# Go to Releases → Click on release → Delete release
```

## Common Commands

### List all tags
```bash
git tag -l
```

### View tag details
```bash
git show v1.0.0
```

### Create release from current commit
```bash
git tag -a v1.0.0 -m "Release message"
git push origin v1.0.0
```

### Create release from specific commit
```bash
git tag -a v1.0.0 <commit-hash> -m "Release message"
git push origin v1.0.0
```

## What Gets Built

Each release includes:

1. **ZIP Archive** (`EyeReminder-v1.0.0.zip`)
   - Contains the `.app` bundle
   - Ready to extract and use

2. **DMG Installer** (`EyeReminder-v1.0.0.dmg`)
   - Disk image with drag-to-install interface
   - Includes Applications folder shortcut

3. **Checksums** (`checksums.txt`)
   - SHA-256 checksums for verification

## Build Process

The GitHub Actions workflow automatically:

1. ✅ Checks out your code
2. ✅ Builds the app with Xcode
3. ✅ Creates ZIP archive
4. ✅ Creates DMG installer
5. ✅ Generates checksums
6. ✅ Creates GitHub release with all files
7. ✅ Adds release notes

## Troubleshooting

### Build fails?
- Check the Actions logs: https://github.com/YOUR_USERNAME/eye-reminder/actions
- Make sure the code builds locally first: `cd EyeReminder && xcodebuild -project EyeReminder.xcodeproj -scheme EyeReminder -configuration Release build`

### Tag already exists?
```bash
# Delete and recreate
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
git tag -a v1.0.0 -m "New message"
git push origin v1.0.0
```

### Release not triggered?
- Make sure tag starts with `v` (e.g., `v1.0.0` not `1.0.0`)
- Check that workflows are enabled in GitHub Settings → Actions

## Testing Locally Before Release

Before creating a release, test the build locally:

```bash
cd EyeReminder

# Clean and build
xcodebuild \
  -project EyeReminder.xcodeproj \
  -scheme EyeReminder \
  -configuration Release \
  clean build

# Check the output
ls -la build/Build/Products/Release/EyeReminder.app
```

## Release Checklist

Before creating a release, make sure:

- [ ] All features are tested and working
- [ ] Version number is updated (if needed)
- [ ] CHANGELOG.md is updated (if you have one)
- [ ] README.md is up to date
- [ ] Code builds locally without errors
- [ ] All commits are pushed to `main`
- [ ] Tag follows semantic versioning (`vX.Y.Z`)

## Next Steps After Release

After a successful release:

1. ✅ Download and test the release files
2. ✅ Share the release link with users
3. ✅ Update any documentation if needed
4. ✅ Announce the release (social media, website, etc.)

---

## Example: Complete Release Process

Here's a complete example of creating version 1.0.0:

```bash
# Navigate to project
cd /Users/dungne/SourceCode/eye-reminder

# Make sure you're on main branch
git checkout main
git pull origin main

# Make your changes (if any)
# ... edit files ...

# Commit changes
git add .
git commit -m "Add new feature for v1.0.0"
git push origin main

# Create and push tag
git tag -a v1.0.0 -m "Release version 1.0.0

Features:
- Menu bar integration
- Customizable intervals
- Full-screen overlay
- Launch at login option
"

git push origin v1.0.0

# Monitor at: https://github.com/YOUR_USERNAME/eye-reminder/actions
# View release at: https://github.com/YOUR_USERNAME/eye-reminder/releases/tag/v1.0.0
```

---

## Need Help?

- 📖 Full documentation: See `GITHUB_ACTIONS_SETUP.md`
- 🐛 Issues: https://github.com/YOUR_USERNAME/eye-reminder/issues
- 💬 Discussions: https://github.com/YOUR_USERNAME/eye-reminder/discussions

---

**Happy releasing! 🚀**
