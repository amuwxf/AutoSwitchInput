#!/bin/bash
set -euo pipefail

# ============================================
# Build script for AutoSwitchInputMethod
# Compiles Swift sources into a macOS .app bundle,
# then deploys a copy to /Applications (keeps the
# install location in sync with the workspace build).
# ============================================

APP_NAME="AutoSwitchInput"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$PROJECT_DIR/Sources"
RES_DIR="$PROJECT_DIR/Resources"
BUNDLE_DIR="$PROJECT_DIR/$APP_NAME.app"
INSTALL_PATH="/Applications/$APP_NAME.app"

echo "=========================================="
echo "  Building $APP_NAME"
echo "=========================================="

# --- 1. Prepare bundle structure ---
echo "[1/5] Creating .app bundle structure..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# --- 2. Compile ---
echo "[2/5] Compiling Swift sources..."
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
swiftc \
    -target arm64-apple-macosx14.0 \
    -sdk "$SDK_PATH" \
    -framework Cocoa \
    -framework Carbon \
    -framework SwiftUI \
    -framework ServiceManagement \
    -O \
    "$SRC_DIR"/*.swift \
    -o "$BUNDLE_DIR/Contents/MacOS/$APP_NAME"

echo "  -> Compiled successfully"

# --- 3. Copy Info.plist ---
echo "[3/5] Copying Info.plist..."
cp "$RES_DIR/Info.plist" "$BUNDLE_DIR/Contents/Info.plist"

# --- 3b. Copy app icon (if present) ---
if [ -f "$RES_DIR/AppIcon.icns" ]; then
    cp "$RES_DIR/AppIcon.icns" "$BUNDLE_DIR/Contents/Resources/AppIcon.icns"
    echo "  -> App icon copied"
fi

# --- 4. Code sign (ad-hoc) ---
echo "[4/5] Code signing (ad-hoc)..."
codesign --force --deep --sign - "$BUNDLE_DIR"

# --- 5. Deploy to /Applications ---
echo "[5/5] Deploying to /Applications..."
if [ -d "$INSTALL_PATH" ]; then
    # 若安装副本正在运行，先退出，避免覆盖运行中的应用
    if pgrep -f "$INSTALL_PATH/Contents/MacOS/$APP_NAME" >/dev/null 2>&1; then
        echo "  -> Quitting running instance..."
        pkill -f "$INSTALL_PATH/Contents/MacOS/$APP_NAME"
        sleep 0.5
    fi
    rm -rf "$INSTALL_PATH"
fi
cp -R "$BUNDLE_DIR" "$INSTALL_PATH"
# 拷贝后签名保持不变（ad-hoc 签名基于内容哈希，内容未变则无需重签，
# 避免 CDHash 变化导致已授予的 TCC 权限（如完整磁盘访问）被重置）
echo "  -> Installed at $INSTALL_PATH"

echo ""
echo "=========================================="
echo "  Build complete!"
echo "  Output:   $BUNDLE_DIR"
echo "  Installed: $INSTALL_PATH"
echo "=========================================="
echo ""
echo "To run:"
echo "  open '$INSTALL_PATH'"
echo ""
echo "If macOS blocks the app, go to:"
echo "  System Settings > Privacy & Security > Allow Anyway"
