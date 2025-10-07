#!/bin/bash

# Debug script for FFmpeg SCTE-35 build issues
# This script helps diagnose common build problems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FFmpeg SCTE-35 Build Debug Script${NC}"
echo "====================================="

# Check if we're in the right directory
if [ ! -f "patches/ffmpeg/ffmpeg-20342.patch" ]; then
    echo -e "${RED}❌ SCTE-35 patch not found!${NC}"
    echo "Expected: patches/ffmpeg/ffmpeg-20342.patch"
    echo "Current directory: $(pwd)"
    echo "Files in patches/ffmpeg/:"
    ls -la patches/ffmpeg/ 2>/dev/null || echo "patches/ffmpeg/ directory not found"
    exit 1
fi

echo -e "${GREEN}✅ SCTE-35 patch found: patches/ffmpeg/ffmpeg-20342.patch${NC}"

# Check patch content
echo -e "\n${YELLOW}Checking patch content...${NC}"
if grep -q "SCTE" patches/ffmpeg/ffmpeg-20342.patch; then
    echo -e "${GREEN}✅ Patch contains SCTE-35 references${NC}"
else
    echo -e "${RED}❌ Patch doesn't contain SCTE-35 references${NC}"
fi

# Check if patch can be applied
echo -e "\n${YELLOW}Testing patch application...${NC}"
if command -v patch &> /dev/null; then
    echo -e "${GREEN}✅ Patch utility available${NC}"
else
    echo -e "${RED}❌ Patch utility not found${NC}"
    echo "Install with: sudo apt-get install patch (Ubuntu/Debian)"
    echo "Or: brew install patch (macOS)"
fi

# Check build dependencies
echo -e "\n${YELLOW}Checking build dependencies...${NC}"

# Check for essential build tools
for tool in gcc make autoconf automake pkg-config; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}✅ $tool: $(which $tool)${NC}"
    else
        echo -e "${RED}❌ $tool: Not found${NC}"
    fi
done

# Check for FFmpeg dependencies
echo -e "\n${YELLOW}Checking FFmpeg dependencies...${NC}"
for lib in libx264 libx265 libvpx libfdk-aac libmp3lame libopus; do
    if pkg-config --exists $lib 2>/dev/null; then
        echo -e "${GREEN}✅ $lib: $(pkg-config --modversion $lib)${NC}"
    else
        echo -e "${YELLOW}⚠️  $lib: Not found (may be installed via package manager)${NC}"
    fi
done

# Check GitHub Actions workflow
echo -e "\n${YELLOW}Checking GitHub Actions workflow...${NC}"
if [ -f ".github/workflows/build-ffmpeg-scte35-simple.yml" ]; then
    echo -e "${GREEN}✅ Simple workflow found${NC}"
else
    echo -e "${RED}❌ Simple workflow not found${NC}"
fi

if [ -f ".github/workflows/build-ffmpeg-scte35-20342.yml" ]; then
    echo -e "${GREEN}✅ Complex workflow found${NC}"
else
    echo -e "${RED}❌ Complex workflow not found${NC}"
fi

# Check for common issues
echo -e "\n${YELLOW}Checking for common issues...${NC}"

# Check if we're in a git repository
if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git repository detected${NC}"
    echo "Current branch: $(git branch --show-current)"
    echo "Last commit: $(git log -1 --oneline)"
else
    echo -e "${YELLOW}⚠️  Not in a git repository${NC}"
fi

# Check file permissions
echo -e "\n${YELLOW}Checking file permissions...${NC}"
if [ -x "build.sh" ]; then
    echo -e "${GREEN}✅ build.sh is executable${NC}"
else
    echo -e "${RED}❌ build.sh is not executable${NC}"
    echo "Fix with: chmod +x build.sh"
fi

# Check for Docker (if using Docker builds)
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker available${NC}"
    if docker info &> /dev/null; then
        echo -e "${GREEN}✅ Docker daemon running${NC}"
    else
        echo -e "${RED}❌ Docker daemon not running${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker not available (needed for some builds)${NC}"
fi

# Provide troubleshooting steps
echo -e "\n${BLUE}Troubleshooting Steps:${NC}"
echo "========================"

echo -e "\n${YELLOW}1. If GitHub Actions is failing:${NC}"
echo "   - Check the Actions tab in your GitHub repository"
echo "   - Look for error messages in the build logs"
echo "   - Try the simple workflow first: build-ffmpeg-scte35-simple.yml"

echo -e "\n${YELLOW}2. If local build is failing:${NC}"
echo "   - Install missing dependencies"
echo "   - Check if the patch applies correctly"
echo "   - Verify FFmpeg source download"

echo -e "\n${YELLOW}3. If patch application fails:${NC}"
echo "   - Check FFmpeg version compatibility"
echo "   - Verify patch file integrity"
echo "   - Try applying patch manually"

echo -e "\n${YELLOW}4. Common fixes:${NC}"
echo "   - Update dependencies: sudo apt-get update && sudo apt-get upgrade"
echo "   - Install build tools: sudo apt-get install build-essential"
echo "   - Check disk space: df -h"
echo "   - Check memory: free -h"

echo -e "\n${GREEN}Debug completed!${NC}"
echo "If you're still having issues, check the GitHub Actions logs for specific error messages."
