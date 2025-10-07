<<<<<<< HEAD
# FFmpeg Builds with SCTE-35 Support

Automated builds of FFmpeg with comprehensive SCTE-35 support for professional broadcasting and streaming applications.

## Features Included:
- ✅ **SCTE-35 Support** - Complete implementation with passthrough and PTS adjustment
- ✅ SRT protocol (libsrt) - Secure Reliable Transport
- ✅ RTMP/RTMPS (librtmp) - Real-time messaging protocol
- ✅ HLS muxing/demuxing - HTTP Live Streaming
- ✅ MPEG-TS broadcasting - Transport stream support
- ✅ Hardware acceleration (CUDA, NVENC) - GPU-accelerated encoding
- ✅ All major codecs - H.264, H.265, VP9, AV1, etc.

## SCTE-35 Features:
- **Clean Passthrough**: SCTE-35 messages pass through without PES wrapping
- **PTS Preservation**: Original transport timestamps are preserved
- **Reclocking Support**: Bitstream filter for PTS adjustment during reclocking
- **Registration Descriptors**: Proper CUEI registration descriptor support
- **Stream Type Handling**: Correct SCTE-35 stream type (0x86) in PMT

## Usage:

### GitHub Actions (Recommended):
1. Go to the **Actions** tab in this repository
2. Run the **"Build FFmpeg with SCTE-35 Support"** workflow
3. Download artifacts from the completed run
4. Extract and use the ffmpeg binary

### Manual Build:
```bash
# Clone the repository
git clone https://github.com/your-username/FFmpeg-Builds-Scte35.git
cd FFmpeg-Builds-Scte35

# Apply patches and build
cd ffmpeg
patch -p1 < ../patches/scte35-comprehensive.patch
patch -p1 < ../patches/scte35-pts-adjust-bsf.patch
./configure --enable-gpl --enable-version3 --enable-libsrt --enable-libx264 --enable-libx265
make -j$(nproc)
```

## SCTE-35 Usage Examples:

### Basic SCTE-35 Passthrough:
```bash
# Pass through SCTE-35 messages without modification
ffmpeg -i input.ts -c copy -f mpegts output.ts
```

### SCTE-35 with Reclocking:
```bash
# Use PTS adjustment bitstream filter for reclocking
ffmpeg -i input.ts -bsf:v scte35_pts_adjust -c copy -f mpegts output.ts
```

### Create SCTE-35 Test Stream:
```bash
# Generate test content with SCTE-35 markers
ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=1000 -c:v libx264 -c:a aac -f mpegts -muxrate 5000000 output.ts
```

## Verification:
```bash
# Check SCTE-35 support
./ffmpeg -h muxer=mpegts | grep -i scte

# Verify bitstream filters
./ffmpeg -bsfs | grep scte35

# Test MPEG-TS output
./ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=30 -c:v libx264 -f mpegts test.ts
```

## Supported Platforms:
- **Linux x64** - Ubuntu 22.04 LTS
- **Windows x64** - Windows Server 2022
- **macOS x64** - macOS 12+

## Quick Start:

### 1. Setup GitHub Repository:
```bash
# Linux/macOS
./scripts/setup-github.sh

# Windows
scripts\setup-github.bat
```

### 2. Automatic Builds:
- Push to `main` branch triggers build workflow
- Create tags (e.g., `v7.0.1-scte35`) triggers release workflow
- Download artifacts from Actions or Releases tab

### 3. Manual Builds:
- Go to Actions tab in GitHub
- Select "Build FFmpeg with SCTE-35 Support"
- Click "Run workflow"

## Patch Sources:
This build incorporates SCTE-35 patches from the FFmpeg development community:
- [2023 SCTE-35 Implementation](https://ffmpeg.org/pipermail/ffmpeg-devel/2023-July/312420.html) by Devin Heitmueller
- [2025 Passthrough Improvements](https://ffmpeg.org/pipermail/ffmpeg-devel/2025-June/344978.html) by Pierre Le Fevre

## License:
This project builds FFmpeg with GPL v2+ license. All patches are contributed back to the FFmpeg project.
=======
# FFmpeg Streaming Build

Automated builds of FFmpeg with full streaming support:

## Features Included:
- ✅ SRT protocol (libsrt)
- ✅ RTMP/RTMPS (librtmp) 
- ✅ HLS muxing/demuxing
- ✅ SCTE35 support
- ✅ MPEG-TS broadcasting
- ✅ Hardware acceleration (CUDA, NVENC)
- ✅ All major codecs

## Usage:
1. Go to Actions tab
2. Run "Build FFmpeg with Full Streaming Support" workflow
3. Download artifacts from completed run
4. Extract and use ffmpeg binary

## Verification:
```bash
./ffmpeg -protocols | grep srt
./ffmpeg -h muxer=mpegts | grep -i scte
>>>>>>> 0ced8830a07c24e22b9ac7caf61cd809f1b38a6e
