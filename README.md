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
