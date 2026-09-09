#!/usr/bin/env bash
# Boots an iOS Simulator and an Android emulator (if they aren't already
# running) and launches the app on both at once.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Checking for Flutter..."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter isn't installed or isn't on your PATH. See the README's 'Install the tools' step first."
  exit 1
fi

# --- iOS Simulator -----------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  if ! xcrun simctl list devices | grep -q "(Booted)"; then
    echo "Starting an iOS Simulator..."
    flutter emulators --launch apple_ios_simulator >/dev/null 2>&1 || true
  else
    echo "An iOS Simulator is already running."
  fi
else
  echo "Skipping iOS (not on a Mac)."
fi

# --- Android emulator ----------------------------------------------------
ANDROID_RUNNING=false
if command -v adb >/dev/null 2>&1 && adb devices | grep -q "emulator-.*device$"; then
  ANDROID_RUNNING=true
  echo "An Android emulator is already running."
fi

if [[ "$ANDROID_RUNNING" == "false" ]]; then
  ANDROID_EMULATOR_ID="$(flutter emulators 2>/dev/null | awk -F'•' '/android/ {gsub(/ /, "", $1); print $1; exit}')"
  if [[ -z "$ANDROID_EMULATOR_ID" ]]; then
    echo "No Android emulator was found."
    echo "Open Android Studio > More Actions > Virtual Device Manager and create one (any phone, default settings are fine), then run this script again."
    exit 1
  fi
  echo "Starting the Android emulator ($ANDROID_EMULATOR_ID)..."
  EMULATOR_BIN="$(command -v emulator || true)"
  if [[ -z "$EMULATOR_BIN" && -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/emulator/emulator" ]]; then
    EMULATOR_BIN="$ANDROID_HOME/emulator/emulator"
  fi
  if [[ -n "$EMULATOR_BIN" ]]; then
    # -no-snapshot-load: a stale saved snapshot can otherwise leave adb stuck
    # reporting the device as "offline" forever.
    "$EMULATOR_BIN" -avd "$ANDROID_EMULATOR_ID" -no-snapshot-load -no-boot-anim >/dev/null 2>&1 &
  else
    flutter emulators --launch "$ANDROID_EMULATOR_ID" &
  fi
fi

# --- Wait for both to come online ----------------------------------------
echo "Waiting for devices to finish booting (this can take a minute the first time)..."
for i in $(seq 1 90); do
  IOS_READY=false
  ANDROID_READY=false
  if [[ "$(uname)" == "Darwin" ]] && xcrun simctl list devices | grep -q "(Booted)"; then
    IOS_READY=true
  fi
  if command -v adb >/dev/null 2>&1 && adb devices | grep -q "emulator-.*device$"; then
    ANDROID_READY=true
  fi
  if [[ "$IOS_READY" == "true" && "$ANDROID_READY" == "true" ]]; then
    break
  fi
  sleep 2
done

echo "Launching the app..."
flutter run -d all
