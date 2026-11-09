#!/bin/zsh
# Builds the test app, runs scenarios, and saves a screenshot and logs for each one.
#
# Usage:
#   Scripts/run_scenarios.sh                  run every scenario in scenarios.txt
#   Scripts/run_scenarios.sh camera layers    run only the named scenarios
#
# Output goes to Results/. Map windows open and close while it runs, so leave them alone.

set -u
ROOT=${0:A:h:h}
NAME=ImmersiveMapDocTests
BUILD=$ROOT/build
OUT=$ROOT/Results
TOOLS=$BUILD/tools
APP=$BUILD/DerivedData/Build/Products/Debug/$NAME.app
OFFLINE_APP=$BUILD/offline/$NAME.app

mkdir -p "$BUILD"
echo "Building..."
xcodebuild -project "$ROOT/$NAME.xcodeproj" -scheme "$NAME" -configuration Debug \
    -derivedDataPath "$BUILD/DerivedData" -skipPackagePluginValidation build > "$BUILD/build.log" 2>&1
if [ $? -ne 0 ]; then
    grep -E " error:" "$BUILD/build.log" | sort -u
    echo "Build failed. Full log: $BUILD/build.log"
    exit 1
fi

mkdir -p "$TOOLS"
for tool in window_id contact_sheet; do
    swiftc -O "$ROOT/Scripts/$tool.swift" -o "$TOOLS/$tool" 2>/dev/null || { echo "Could not compile $tool"; exit 1; }
done

rm -rf "$OUT"
mkdir -p "$OUT/small"

python3 -I "$ROOT/Scripts/header_server.py" > "$OUT/headers.server.log" 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null; pkill -x $NAME' EXIT

make_offline_app() {
    rm -rf "$BUILD/offline"
    mkdir -p "$BUILD/offline"
    cp -R "$APP" "$BUILD/offline/"
    /usr/libexec/PlistBuddy -c "Clear dict" \
        -c "Add :com.apple.security.app-sandbox bool true" \
        -c "Add :com.apple.security.files.user-selected.read-only bool true" \
        -c "Add :com.apple.security.get-task-allow bool true" "$BUILD/offline/entitlements.plist" >/dev/null 2>&1
    codesign --force --sign - --entitlements "$BUILD/offline/entitlements.plist" "$OFFLINE_APP" > "$OUT/resign.log" 2>&1
}

run_one() {
    local scenario=$1 wait_seconds=$2 target=$APP
    if [ "$scenario" = cached ]; then
        make_offline_app
        target=$OFFLINE_APP
    fi
    open -n --stdout "$OUT/$scenario.log" --stderr "$OUT/$scenario.err" --env OS_ACTIVITY_DT_MODE=1 "$target" --args -scenario "$scenario"
    sleep "$wait_seconds"
    local pid=$(pgrep -x $NAME | head -1)
    local window=$("$TOOLS/window_id" $NAME | head -1)
    if [ -n "$window" ]; then
        screencapture -x -o -l "$window" "$OUT/$scenario.png"
        sips -Z 1000 "$OUT/$scenario.png" --out "$OUT/small/$scenario.png" >/dev/null 2>&1
    else
        echo "$scenario NO_WINDOW" | tee -a "$OUT/status.txt"
    fi
    if [ -n "$pid" ]; then
        kill "$pid"
        echo "$scenario alive" >> "$OUT/status.txt"
    else
        echo "$scenario EXITED" | tee -a "$OUT/status.txt"
    fi
    sleep 1
}

pkill -x $NAME
sleep 1

names=()
while read -r scenario seconds; do
    [[ -z "$scenario" || "$scenario" == \#* ]] && continue
    if [ $# -eq 0 ] || (( ${@[(Ie)$scenario]} )); then
        echo "$scenario"
        run_one "$scenario" "$seconds"
        names+=("$scenario")
    fi
done < "$ROOT/Scripts/scenarios.txt"

sheet=1
for (( i = 1; i <= ${#names}; i += 8 )); do
    "$TOOLS/contact_sheet" "$OUT/sheet-$sheet.png" "$OUT/small" "${names[@]:$((i - 1)):8}"
    (( sheet++ ))
done

echo
echo "Logged values:"
grep -H '\[T\]' "$OUT"/*.log | sed "s#$OUT/##; s/\.log:\[T\]/:/" | cut -c1-220
echo
echo "Finished ${#names} scenarios. Results: $OUT"
