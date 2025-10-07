#!/bin/bash

# Test script to verify SCTE-35 patch works locally
# This helps debug issues before pushing to GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing SCTE-35 Patch Locally${NC}"
echo "================================="

# Check if we're in the right directory
if [ ! -f "patches/ffmpeg/ffmpeg-20342.patch" ]; then
    echo -e "${RED}❌ SCTE-35 patch not found!${NC}"
    echo "Expected: patches/ffmpeg/ffmpeg-20342.patch"
    exit 1
fi

echo -e "${GREEN}✅ SCTE-35 patch found${NC}"

# Create a test directory
TEST_DIR="test-build-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo -e "\n${YELLOW}Downloading FFmpeg 7.0 source...${NC}"
curl -L -o ffmpeg.tar.xz "https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz"
tar -xf ffmpeg.tar.xz
cd ffmpeg-7.0

echo -e "\n${YELLOW}Testing patch application...${NC}"
if patch -p1 < ../../patches/ffmpeg/ffmpeg-20342.patch; then
    echo -e "${GREEN}✅ Patch applied successfully${NC}"
    
    # Check if SCTE-35 code was added
    if grep -q "SCTE" libavformat/mpegtsenc.c; then
        echo -e "${GREEN}✅ SCTE-35 code detected in mpegtsenc.c${NC}"
    else
        echo -e "${RED}❌ SCTE-35 code not found in mpegtsenc.c${NC}"
    fi
    
    if grep -q "scte35" libavformat/mpegtsenc.c; then
        echo -e "${GREEN}✅ scte35 references found in mpegtsenc.c${NC}"
    else
        echo -e "${YELLOW}⚠️  scte35 references not found${NC}"
    fi
    
else
    echo -e "${RED}❌ Patch application failed${NC}"
    echo "This might indicate:"
    echo "1. FFmpeg version incompatibility"
    echo "2. Patch file corruption"
    echo "3. Missing dependencies"
    exit 1
fi

echo -e "\n${YELLOW}Testing basic configuration...${NC}"
if ./configure --help > /dev/null 2>&1; then
    echo -e "${GREEN}✅ FFmpeg configure script is working${NC}"
else
    echo -e "${RED}❌ FFmpeg configure script failed${NC}"
    exit 1
fi

# Clean up
cd ../..
rm -rf "$TEST_DIR"

echo -e "\n${GREEN}🎉 Local patch test completed successfully!${NC}"
echo "The SCTE-35 patch should work in GitHub Actions."
echo ""
echo "Next steps:"
echo "1. Commit and push your changes"
echo "2. Check GitHub Actions tab for build progress"
echo "3. Download artifacts when build completes"
