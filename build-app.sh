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
# A stable identity keeps the Accessibility permission across rebuilds (see setup-signing.sh); fall back to ad hoc.
if security find-identity -p codesigning | grep -q "Paste Local Signing"; then
    codesign --force --sign "Paste Local Signing" "$APP"
else
    echo "Note: no 'Paste Local Signing' identity; signing ad hoc. Run ./setup-signing.sh once."
    codesign --force --sign - "$APP"
fi
echo "Built $APP"
