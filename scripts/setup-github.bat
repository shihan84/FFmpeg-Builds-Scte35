@echo off
REM GitHub Repository Setup Script for FFmpeg SCTE-35 Builds
REM This script helps set up the GitHub repository with proper configuration

setlocal enabledelayedexpansion

echo GitHub Repository Setup for FFmpeg SCTE-35 Builds
echo ========================================================

REM Check if git is initialized
if not exist ".git" (
    echo Initializing Git repository...
    git init
    git branch -M main
) else (
    echo Git repository already initialized
)

REM Check if remote origin exists
git remote get-url origin >nul 2>&1
if !errorlevel! neq 0 (
    echo Please add your GitHub repository as origin:
    echo git remote add origin https://github.com/YOUR_USERNAME/FFmpeg-Builds-Scte35.git
    echo.
    pause
)

REM Add all files
echo Adding files to Git...
git add .

REM Create initial commit
echo Creating initial commit...
git commit -m "Initial commit: FFmpeg 7.0 with comprehensive SCTE-35 support

- Added GitHub Actions workflows for multi-platform builds
- Included comprehensive SCTE-35 patches from FFmpeg community
- Enabled all streaming libraries and non-free codecs
- Added local build scripts for Linux, Windows, and macOS
- Configured automatic releases with artifacts"

REM Push to GitHub
echo Pushing to GitHub...
git push -u origin main

REM Create initial release tag
echo Creating initial release tag...
git tag -a v7.0.0-scte35 -m "FFmpeg 7.0 with SCTE-35 Support - Initial Release"
git push origin v7.0.0-scte35

echo Repository setup completed!
echo.
echo Next steps:
echo 1. Go to your GitHub repository
echo 2. Check the Actions tab to see the build workflows
echo 3. The initial release will be created automatically
echo 4. Download artifacts from the completed build
echo.
echo To trigger a new release:
echo git tag -a v7.0.1-scte35 -m "Release v7.0.1"
echo git push origin v7.0.1-scte35
echo.
echo To run builds manually:
echo 1. Go to Actions tab in GitHub
echo 2. Select "Build FFmpeg with SCTE-35 Support"
echo 3. Click "Run workflow"
