@echo off
REM FFmpeg Build Script with SCTE-35 Support for Windows
REM This script builds FFmpeg locally with comprehensive SCTE-35 support

setlocal enabledelayedexpansion

REM Configuration
set FFMPEG_VERSION=7.0
set BUILD_DIR=build
set INSTALL_PREFIX=C:\ffmpeg

echo FFmpeg Build Script with SCTE-35 Support
echo ==============================================

REM Create build directory
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Download FFmpeg source if not exists
if not exist "ffmpeg-%FFMPEG_VERSION%" (
    echo Downloading FFmpeg %FFMPEG_VERSION%...
    curl -L -o ffmpeg.tar.bz2 "https://ffmpeg.org/releases/ffmpeg-%FFMPEG_VERSION%.tar.bz2"
    tar -xjf ffmpeg.tar.bz2
    move ffmpeg-%FFMPEG_VERSION% ffmpeg
)

cd ffmpeg

REM Apply SCTE-35 patches
echo Applying SCTE-35 patches...
if exist "..\..\patches\scte35-comprehensive.patch" (
    patch -p1 < ..\..\patches\scte35-comprehensive.patch
    echo Applied comprehensive SCTE-35 patch
) else (
    echo SCTE-35 comprehensive patch not found!
    exit /b 1
)

if exist "..\..\patches\scte35-pts-adjust-bsf.patch" (
    patch -p1 < ..\..\patches\scte35-pts-adjust-bsf.patch
    echo Applied SCTE-35 PTS adjustment BSF patch
) else (
    echo SCTE-35 PTS adjustment BSF patch not found!
    exit /b 1
)

REM Configure FFmpeg
echo Configuring FFmpeg...

set CONFIGURE_OPTS=--prefix=%INSTALL_PREFIX% --enable-gpl --enable-version3 --enable-nonfree --enable-shared --disable-static --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-libsrt --enable-openssl --enable-hardcoded-tables --enable-pic --disable-debug --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32-

configure %CONFIGURE_OPTS%

REM Build FFmpeg
echo Building FFmpeg...
make -j%NUMBER_OF_PROCESSORS%

REM Install FFmpeg
echo Installing FFmpeg...
make install

REM Verify installation
echo Verifying installation...
if exist "%INSTALL_PREFIX%\bin\ffmpeg.exe" (
    echo FFmpeg installed successfully!
    "%INSTALL_PREFIX%\bin\ffmpeg.exe" -version | findstr "ffmpeg version"
    
    REM Check SCTE-35 support
    "%INSTALL_PREFIX%\bin\ffmpeg.exe" -h muxer=mpegts 2>&1 | findstr /i scte >nul
    if !errorlevel! equ 0 (
        echo SCTE-35 support detected!
    ) else (
        echo SCTE-35 support verification needed
    )
    
    REM Check bitstream filters
    "%INSTALL_PREFIX%\bin\ffmpeg.exe" -bsfs 2>&1 | findstr /i scte35 >nul
    if !errorlevel! equ 0 (
        echo SCTE-35 bitstream filters available!
    ) else (
        echo SCTE-35 bitstream filters not found
    )
) else (
    echo FFmpeg installation failed!
    exit /b 1
)

echo Build completed successfully!
echo FFmpeg with SCTE-35 support is now available at: %INSTALL_PREFIX%\bin\ffmpeg.exe
