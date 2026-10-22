#!/bin/sh
# Builds Paste and bundles it as build/Paste.app (Command Line Tools only, no Xcode).
set -e
cd "$(dirname "$0")"
swift build -c release
APP=build/Paste.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Paste" "$APP/Contents/MacOS/Paste"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.matthew.paste</string>
    <key>CFBundleName</key><string>Paste</string>
    <key>CFBundleExecutable</key><string>Paste</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>0.1</string>
    <key>LSMinimumSystemVersion</key><string>26.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST
codesign --force --sign - "$APP"
echo "Built $APP"
