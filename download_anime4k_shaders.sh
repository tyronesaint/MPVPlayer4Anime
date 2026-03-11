#!/bin/bash

# Anime4K Shader Downloader for VLC iOS
# Downloads Anime4K GLSL shaders from the official repository

set -e

echo "═══════════════════════════════════════════════════"
echo "🎬 Anime4K Shader Downloader"
echo "═══════════════════════════════════════════════════"
echo ""

# Configuration
ANIME4K_REPO="https://github.com/bloc97/Anime4K.git"
TEMP_DIR="anime4k_temp"
SHADER_DIR="vlc-ios/Resources/Shaders/Anime4K"

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed. Please install it first."
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ git is not installed. Please install it first."
    exit 1
fi

# Create shader directory
echo "📁 Creating shader directory..."
mkdir -p "$SHADER_DIR"

# Clone Anime4K repository
echo "📥 Cloning Anime4K repository..."
if [ -d "$TEMP_DIR" ]; then
    echo "⚠️  Temporary directory already exists, removing..."
    rm -rf "$TEMP_DIR"
fi

git clone --depth 1 "$ANIME4K_REPO" "$TEMP_DIR"

# Copy GLSL shaders
echo "📦 Copying GLSL shaders..."
if [ -d "$TEMP_DIR/glsl" ]; then
    cp -r "$TEMP_DIR/glsl"/* "$SHADER_DIR/"
    echo "✅ Shaders copied successfully"
else
    echo "❌ glsl directory not found in Anime4K repository"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy shaders if they are in a different location
if [ -d "$TEMP_DIR/shaders" ]; then
    cp -r "$TEMP_DIR/shaders"/* "$SHADER_DIR/"
    echo "✅ Additional shaders copied"
fi

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

# List downloaded shaders
echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ Download Complete!"
echo "═══════════════════════════════════════════════════"
echo "📍 Shader Directory: $SHADER_DIR"
echo ""
echo "📝 Downloaded Shaders:"
ls -lh "$SHADER_DIR"/*.glsl 2>/dev/null || echo "No .glsl files found"
echo ""

# Count shaders
SHADER_COUNT=$(find "$SHADER_DIR" -name "*.glsl" | wc -l)
echo "📊 Total Shaders: $SHADER_COUNT"
echo ""

echo "═══════════════════════════════════════════════════"
echo "🎉 Anime4K shaders are ready to use!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Add the shaders to your Xcode project"
echo "2. Select 'Copy items if needed' when adding"
echo "3. Build and test with Anime4KShaderManager"
echo ""
