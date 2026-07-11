#!/bin/bash
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
APP="BlockSort.app"
BUILD="build"
DIST="$ROOT/dist"

echo "==> clean"
rm -rf "$BUILD" "$APP" AppIcon.icns BlockSort.iconset
mkdir -p "$BUILD"

echo "==> compile BlockSortApp.swift"
swiftc -O -o "$BUILD/BlockSort" BlockSortApp.swift -framework Cocoa -framework WebKit

echo "==> AppIcon.icns from icon-512.png"
mkdir -p BlockSort.iconset
SRC="$ROOT/icon-512.png"
for s in 16 32 128 256 512; do
  sips -z $s $s "$SRC" --out "BlockSort.iconset/icon_${s}x${s}.png" >/dev/null
  d=$((s*2)); sips -z $d $d "$SRC" --out "BlockSort.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns BlockSort.iconset -o AppIcon.icns

echo "==> assemble $APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/web"
cp "$BUILD/BlockSort" "$APP/Contents/MacOS/BlockSort"; chmod +x "$APP/Contents/MacOS/BlockSort"
cp Info.plist "$APP/Contents/Info.plist"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
for f in index.html manifest.json sw.js icon-180.png icon-192.png icon-512.png; do
  [ -f "$ROOT/$f" ] && cp "$ROOT/$f" "$APP/Contents/Resources/web/$f"
done

echo "==> ad-hoc sign"
codesign --force --deep --sign - "$APP" 2>/dev/null || echo "  (ad-hoc warning ok)"

echo "==> DMG"
mkdir -p "$DIST"
STAGE="$BUILD/dmg"; rm -rf "$STAGE"; mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"; ln -s /Applications "$STAGE/Applications"
DMG="$DIST/BlockSort-v30.dmg"; rm -f "$DMG"
hdiutil create -volname "Block Sort" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null

echo "==> done:"; ls -lh "$DMG" | awk '{print "   "$5"  "$NF}'
