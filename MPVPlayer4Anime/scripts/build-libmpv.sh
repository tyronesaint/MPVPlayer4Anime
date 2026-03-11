#!/bin/bash

set -e

echo "═══════════════════════════════════════════════════"
echo "🚀 MPVPlayer4Anime - libmpv Build Script"
echo "═══════════════════════════════════════════════════"
echo ""

# 检查依赖
echo "🔍 Checking dependencies..."
if ! command -v meson &> /dev/null; then
    echo "❌ Meson is not installed!"
    echo "   Install with: brew install meson"
    exit 1
fi

if ! command -v ninja &> /dev/null; then
    echo "❌ Ninja is not installed!"
    echo "   Install with: brew install ninja"
    exit 1
fi

if ! command -v xcrun &> /dev/null; then
    echo "❌ Xcode command line tools are not installed!"
    echo "   Install with: xcode-select --install"
    exit 1
fi

echo "✅ All dependencies are installed"
echo ""

# ⚠️ iOS 15.0 最低版本
MPV_VERSION="0.38.0"
IOS_DEPLOYMENT_TARGET="15.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/../Dependencies"
MPV_SOURCE_DIR="${BUILD_DIR}/mpv-${MPV_VERSION}"
INSTALL_DIR="${BUILD_DIR}/install"

# 架构列表
ARCHS="arm64 x86_64"

# 清理并创建目录
echo "🧹 Cleaning build directory..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${BUILD_DIR}"

# 下载 mpv 源码
if [ ! -d "${MPV_SOURCE_DIR}" ]; then
    echo "📥 Downloading mpv ${MPV_VERSION}..."
    cd "${BUILD_DIR}"
    curl -L "https://github.com/mpv-player/mpv/archive/refs/tags/v${MPV_VERSION}.tar.gz" -o "mpv-${MPV_VERSION}.tar.gz"
    echo "📦 Extracting archive..."
    tar xzf "mpv-${MPV_VERSION}.tar.gz"
    rm "mpv-${MPV_VERSION}.tar.gz"
    echo "✅ Source code extracted to: ${MPV_SOURCE_DIR}"
fi

# 为每个架构编译
for ARCH in ${ARCHS}; do
    echo ""
    echo "🔨 Building for ${ARCH} (iOS ${IOS_DEPLOYMENT_TARGET}+)..."

    # 设置交叉编译变量
    if [ "${ARCH}" == "arm64" ]; then
        HOST="arm-apple-darwin"
        SDK=iphoneos
    else
        HOST="x86_64-apple-darwin"
        SDK=iphonesimulator
    fi

    # 设置 SDK 路径
    SDK_PATH=$(xcrun --sdk ${SDK} --show-sdk-path)
    echo "📱 SDK: ${SDK}"
    echo "📍 SDK Path: ${SDK_PATH}"

    # 编译 mpv
    cd "${MPV_SOURCE_DIR}"

    # 清理之前的构建目录
    echo "🧹 Cleaning previous build..."
    rm -rf build-${ARCH}
    mkdir -p build-${ARCH}
    cd build-${ARCH}

    # 使用 Meson 配置（mpv 0.38.0 只支持 Meson，不再支持 waf）
    echo "⚙️  Configuring with Meson..."

    # 设置 SDK 路径为环境变量，供 meson 交叉编译文件使用
    export SDKROOT="${SDK_PATH}"

    if ! meson setup \
        --cross-file="${SCRIPT_DIR}/meson-ios-${ARCH}.txt" \
        --default-library=static \
        --prefix="${INSTALL_DIR}/${ARCH}" \
        --buildtype=release \
        -Dlibmpv=true \
        -Dlua=disabled \
        -Djavascript=disabled \
        -Dcocoa=disabled \
        ..; then

        echo "❌ Meson configuration failed!"
        echo "📋 Check the meson log: build-${ARCH}/meson-logs/meson-log.txt"
        exit 1
    fi

    echo "✅ Meson configuration successful"
    echo "🔧 Building with Ninja..."

    if ! ninja; then
        echo "❌ Ninja build failed for ${ARCH}!"
        exit 1
    fi

    echo "✅ Ninja build successful for ${ARCH}"
    ninja install
done

# 合并通用二进制文件
echo ""
echo "🔗 Creating universal binaries..."
mkdir -p "${INSTALL_DIR}/lib"

if [ -f "${INSTALL_DIR}/arm64/lib/libmpv.a" ] && [ -f "${INSTALL_DIR}/x86_64/lib/libmpv.a" ]; then
    lipo -create \
        "${INSTALL_DIR}/arm64/lib/libmpv.a" \
        "${INSTALL_DIR}/x86_64/lib/libmpv.a" \
        -output "${INSTALL_DIR}/lib/libmpv.a"
    echo "✅ Universal binary created: ${INSTALL_DIR}/lib/libmpv.a"
elif [ -f "${INSTALL_DIR}/arm64/lib/libmpv.a" ]; then
    # 只有 arm64
    cp "${INSTALL_DIR}/arm64/lib/libmpv.a" "${INSTALL_DIR}/lib/libmpv.a"
    echo "✅ Using arm64 binary only"
elif [ -f "${INSTALL_DIR}/x86_64/lib/libmpv.a" ]; then
    # 只有 x86_64
    cp "${INSTALL_DIR}/x86_64/lib/libmpv.a" "${INSTALL_DIR}/lib/libmpv.a"
    echo "✅ Using x86_64 binary only"
else
    echo "❌ ERROR: No libmpv.a found!"
    exit 1
fi

# 合并头文件
echo ""
echo "📝 Copying header files..."
mkdir -p "${INSTALL_DIR}/include"

# 从 arm64 复制头文件
if [ -d "${INSTALL_DIR}/arm64/include" ]; then
    cp -r "${INSTALL_DIR}/arm64/include/"* "${INSTALL_DIR}/include/"
    echo "✅ Headers copied from arm64"
elif [ -d "${INSTALL_DIR}/x86_64/include" ]; then
    cp -r "${INSTALL_DIR}/x86_64/include/"* "${INSTALL_DIR}/include/"
    echo "✅ Headers copied from x86_64"
else
    echo "⚠️  No headers found!"
fi

# 显示构建结果
echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ Build Complete!"
echo "═══════════════════════════════════════════════════"
echo "📍 Install Directory: ${INSTALL_DIR}"
echo "📦 Library: ${INSTALL_DIR}/lib/libmpv.a"
echo "📝 Include: ${INSTALL_DIR}/include/"
echo "📱 Minimum iOS Version: ${IOS_DEPLOYMENT_TARGET}"
echo "═══════════════════════════════════════════════════"
echo ""

# 验证文件
if [ -f "${INSTALL_DIR}/lib/libmpv.a" ]; then
    echo "📦 Library file:"
    ls -lh "${INSTALL_DIR}/lib/libmpv.a"
    echo ""
    echo "🔍 Architecture:"
    lipo -info "${INSTALL_DIR}/lib/libmpv.a"
    echo ""
fi

if [ -d "${INSTALL_DIR}/include/mpv" ]; then
    echo "📝 Header files:"
    ls -la "${INSTALL_DIR}/include/mpv/"
fi

echo ""
echo "🎉 All done! You can now build the iOS app."
