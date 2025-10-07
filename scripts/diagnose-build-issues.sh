#!/bin/bash

# Comprehensive build issue diagnosis script
# This helps identify specific problems with FFmpeg SCTE-35 builds

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FFmpeg SCTE-35 Build Issue Diagnosis${NC}"
echo "=========================================="

# Check 1: Repository structure
echo -e "\n${YELLOW}1. Checking repository structure...${NC}"
if [ -f "patches/ffmpeg/ffmpeg-20342.patch" ]; then
    echo -e "${GREEN}✅ SCTE-35 patch found${NC}"
    echo "Patch size: $(wc -c < patches/ffmpeg/ffmpeg-20342.patch) bytes"
    echo "Patch lines: $(wc -l < patches/ffmpeg/ffmpeg-20342.patch) lines"
else
    echo -e "${RED}❌ SCTE-35 patch not found!${NC}"
    echo "Expected location: patches/ffmpeg/ffmpeg-20342.patch"
    exit 1
fi

# Check 2: Patch content validation
echo -e "\n${YELLOW}2. Validating patch content...${NC}"
if grep -q "SCTE" patches/ffmpeg/ffmpeg-20342.patch; then
    echo -e "${GREEN}✅ Patch contains SCTE references${NC}"
else
    echo -e "${RED}❌ Patch doesn't contain SCTE references${NC}"
fi

if grep -q "mpegtsenc.c" patches/ffmpeg/ffmpeg-20342.patch; then
    echo -e "${GREEN}✅ Patch targets mpegtsenc.c${NC}"
else
    echo -e "${RED}❌ Patch doesn't target mpegtsenc.c${NC}"
fi

# Check 3: GitHub Actions workflow files
echo -e "\n${YELLOW}3. Checking GitHub Actions workflows...${NC}"
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" | wc -l)
echo "Found $WORKFLOW_COUNT workflow files:"
find .github/workflows -name "*.yml" -exec basename {} \;

# Check 4: Test patch application
echo -e "\n${YELLOW}4. Testing patch application...${NC}"
if command -v patch &> /dev/null; then
    echo -e "${GREEN}✅ Patch utility available${NC}"
    
    # Create a test environment
    TEST_DIR="patch-test-$(date +%s)"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Download a small FFmpeg version for testing
    echo "Downloading FFmpeg 7.0 for patch testing..."
    if curl -L -o ffmpeg.tar.xz "https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz" 2>/dev/null; then
        tar -xf ffmpeg.tar.xz
        cd ffmpeg-7.0
        
        echo "Testing patch application..."
        if patch -p1 < ../../patches/ffmpeg/ffmpeg-20342.patch 2>/dev/null; then
            echo -e "${GREEN}✅ Patch applies successfully${NC}"
            
            # Check if SCTE-35 code was added
            if grep -q "scte35" libavformat/mpegtsenc.c; then
                echo -e "${GREEN}✅ SCTE-35 code detected in mpegtsenc.c${NC}"
            else
                echo -e "${YELLOW}⚠️  SCTE-35 code not found in mpegtsenc.c${NC}"
            fi
        else
            echo -e "${RED}❌ Patch application failed${NC}"
            echo "This indicates a compatibility issue with FFmpeg 7.0"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not download FFmpeg for testing${NC}"
    fi
    
    # Clean up
    cd ../..
    rm -rf "$TEST_DIR"
else
    echo -e "${RED}❌ Patch utility not found${NC}"
fi

# Check 5: Common build issues
echo -e "\n${YELLOW}5. Checking for common build issues...${NC}"

# Check disk space
DISK_SPACE=$(df -h . | tail -1 | awk '{print $4}')
echo "Available disk space: $DISK_SPACE"

# Check memory
if command -v free &> /dev/null; then
    MEMORY=$(free -h | grep "Mem:" | awk '{print $7}')
    echo "Available memory: $MEMORY"
fi

# Check for common build tools
echo -e "\n${YELLOW}6. Checking build dependencies...${NC}"
for tool in gcc make autoconf automake pkg-config; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}✅ $tool: $(which $tool)${NC}"
    else
        echo -e "${RED}❌ $tool: Not found${NC}"
    fi
done

# Check 7: GitHub Actions specific issues
echo -e "\n${YELLOW}7. GitHub Actions specific checks...${NC}"

# Check if we're in a git repository
if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git repository detected${NC}"
    echo "Current branch: $(git branch --show-current)"
    echo "Remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
else
    echo -e "${RED}❌ Not in a git repository${NC}"
fi

# Check workflow syntax
echo -e "\n${YELLOW}8. Checking workflow syntax...${NC}"
for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        echo "Checking $(basename $workflow)..."
        if grep -q "name:" "$workflow" && grep -q "on:" "$workflow" && grep -q "jobs:" "$workflow"; then
            echo -e "${GREEN}✅ Basic workflow structure looks good${NC}"
        else
            echo -e "${RED}❌ Workflow structure issues detected${NC}"
        fi
    fi
done

# Provide specific troubleshooting steps
echo -e "\n${BLUE}Specific Troubleshooting Steps:${NC}"
echo "=================================="

echo -e "\n${YELLOW}If GitHub Actions is failing:${NC}"
echo "1. Go to your repository: https://github.com/shihan84/FFmpeg-Builds-Scte35"
echo "2. Click on 'Actions' tab"
echo "3. Look for failed workflow runs"
echo "4. Click on the failed run to see detailed logs"
echo "5. Look for specific error messages like:"
echo "   - 'Patch application failed'"
echo "   - 'Configure failed'"
echo "   - 'Build failed'"
echo "   - 'Dependency not found'"

echo -e "\n${YELLOW}If patch application fails:${NC}"
echo "1. Check if FFmpeg version is compatible"
echo "2. Verify patch file integrity"
echo "3. Try different FFmpeg versions (6.1, 6.0, 5.1)"

echo -e "\n${YELLOW}If build fails:${NC}"
echo "1. Check if all dependencies are installed"
echo "2. Verify disk space and memory"
echo "3. Check for conflicting libraries"

echo -e "\n${YELLOW}Quick fixes to try:${NC}"
echo "1. Use the minimal workflow: build-ffmpeg-minimal.yml"
echo "2. Try building with fewer dependencies"
echo "3. Check GitHub Actions logs for specific errors"

echo -e "\n${GREEN}Diagnosis completed!${NC}"
echo "Check the output above for any ❌ errors and follow the troubleshooting steps."
