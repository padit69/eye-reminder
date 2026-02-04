#!/bin/bash

# Test Build Script
# Quickly test if the app builds successfully

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "🔨 Testing Health Reminder Build..."
echo ""

# Navigate to HealthReminder directory
cd "$(dirname "$0")/../HealthReminder"

# Clean and build
echo -e "${BLUE}ℹ️  Cleaning previous builds...${NC}"
xcodebuild \
  -project HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Release \
  -derivedDataPath ./build \
  clean

echo ""
echo -e "${BLUE}ℹ️  Building app...${NC}"
xcodebuild \
  -project HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Release \
  -derivedDataPath ./build \
  build

# Check if build succeeded
if [ -d "build/Build/Products/Release/HealthReminder.app" ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo "Build output:"
    ls -lh build/Build/Products/Release/HealthReminder.app
    echo ""
    echo "App size: $(du -sh build/Build/Products/Release/HealthReminder.app | cut -f1)"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
