#!/bin/bash

# FFmpeg Build Script with SCTE-35 Support
# This script builds FFmpeg locally with comprehensive SCTE-35 support

set -e

# Configuration
FFMPEG_VERSION="7.0"
BUILD_DIR="build"
INSTALL_PREFIX="/usr/local"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}FFmpeg Build Script with SCTE-35 Support${NC}"
echo "=============================================="

# Check if running on supported platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    echo -e "${GREEN}Detected Linux platform${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    echo -e "${GREEN}Detected macOS platform${NC}"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    PLATFORM="windows"
    echo -e "${GREEN}Detected Windows platform${NC}"
else
    echo -e "${RED}Unsupported platform: $OSTYPE${NC}"
    exit 1
fi

# Create build directory
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Download FFmpeg source if not exists
if [ ! -d "ffmpeg-$FFMPEG_VERSION" ]; then
    echo -e "${YELLOW}Downloading FFmpeg $FFMPEG_VERSION...${NC}"
    wget -O ffmpeg.tar.bz2 "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2"
    tar -xjf ffmpeg.tar.bz2
    mv ffmpeg-$FFMPEG_VERSION ffmpeg
fi

cd ffmpeg

# Apply SCTE-35 patches
echo -e "${YELLOW}Applying SCTE-35 patches...${NC}"
if [ -f "../../patches/scte35-comprehensive.patch" ]; then
    patch -p1 < ../../patches/scte35-comprehensive.patch
    echo -e "${GREEN}Applied comprehensive SCTE-35 patch${NC}"
else
    echo -e "${RED}SCTE-35 comprehensive patch not found!${NC}"
    exit 1
fi

if [ -f "../../patches/scte35-pts-adjust-bsf.patch" ]; then
    patch -p1 < ../../patches/scte35-pts-adjust-bsf.patch
    echo -e "${GREEN}Applied SCTE-35 PTS adjustment BSF patch${NC}"
else
    echo -e "${RED}SCTE-35 PTS adjustment BSF patch not found!${NC}"
    exit 1
fi

# Configure FFmpeg
echo -e "${YELLOW}Configuring FFmpeg...${NC}"

CONFIGURE_OPTS="
    --prefix=$INSTALL_PREFIX
    --enable-gpl
    --enable-version3
    --enable-nonfree
    --enable-shared
    --disable-static
    --enable-libass
    --enable-libfdk-aac
    --enable-libfreetype
    --enable-libmp3lame
    --enable-libopus
    --enable-libvorbis
    --enable-libvpx
    --enable-libx264
    --enable-libx265
    --enable-libsrt
    --enable-openssl
    --enable-hardcoded-tables
    --enable-pic
    --disable-debug
    --disable-doc
    --disable-htmlpages
    --disable-manpages
    --disable-podpages
    --disable-txtpages
"

# Platform-specific options
if [[ "$PLATFORM" == "linux" ]]; then
    CONFIGURE_OPTS="$CONFIGURE_OPTS --enable-vaapi --enable-vdpau"
elif [[ "$PLATFORM" == "macos" ]]; then
    CONFIGURE_OPTS="$CONFIGURE_OPTS --enable-videotoolbox"
elif [[ "$PLATFORM" == "windows" ]]; then
    CONFIGURE_OPTS="$CONFIGURE_OPTS --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32-"
fi

./configure $CONFIGURE_OPTS

# Build FFmpeg
echo -e "${YELLOW}Building FFmpeg...${NC}"
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Install FFmpeg
echo -e "${YELLOW}Installing FFmpeg...${NC}"
sudo make install

# Verify installation
echo -e "${YELLOW}Verifying installation...${NC}"
if command -v ffmpeg &> /dev/null; then
    echo -e "${GREEN}FFmpeg installed successfully!${NC}"
    echo "Version: $(ffmpeg -version | head -n1)"
    
    # Check SCTE-35 support
    if ffmpeg -h muxer=mpegts 2>&1 | grep -qi scte; then
        echo -e "${GREEN}SCTE-35 support detected!${NC}"
    else
        echo -e "${YELLOW}SCTE-35 support verification needed${NC}"
    fi
    
    # Check bitstream filters
    if ffmpeg -bsfs 2>&1 | grep -qi scte35; then
        echo -e "${GREEN}SCTE-35 bitstream filters available!${NC}"
    else
        echo -e "${YELLOW}SCTE-35 bitstream filters not found${NC}"
    fi
else
    echo -e "${RED}FFmpeg installation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build completed successfully!${NC}"
echo "FFmpeg with SCTE-35 support is now available at: $INSTALL_PREFIX/bin/ffmpeg"
