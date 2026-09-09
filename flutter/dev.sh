#!/usr/bin/env bash
# Interactive alternative to `flutter run`: asks what to run CareConnect on
# (iPhone, iPad/tablet, or Android), boots it if it isn't already running,
# and launches the app there.
#
# For "boot everything and run on all of it in one shot" (e.g. for grading),
# use ./run.sh instead.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter isn't installed or isn't on your PATH. See the README's 'Install the tools' step first."
  exit 1
fi

# Finds the UDID of the first available (not necessarily booted) iOS
# simulator whose name matches $1, e.g. '^ *iPhone [0-9]' or '^ *iPad\b'.
find_ios_udid() {
  xcrun simctl list devices available 2>/dev/null \
    | grep -E "$1" \
    | head -1 \
    | sed -E 's/.*\(([0-9A-Fa-f-]+)\).*/\1/'
}

boot_ios_simulator() {
  local udid="$1"
  if ! xcrun simctl list devices | grep "$udid" | grep -q "Booted"; then
    echo "Booting simulator..."
    xcrun simctl boot "$udid" 2>/dev/null || true
  fi
  open -a Simulator --args -CurrentDeviceUDID "$udid"
  echo "Waiting for it to finish booting..."
  for _ in $(seq 1 60); do
    xcrun simctl list devices | grep "$udid" | grep -q "Booted" && break
    sleep 1
  done
}

boot_android_emulator() {
  if adb devices 2>/dev/null | grep -q "emulator-.*device$"; then
    echo "An Android emulator is already running."
    return
  fi
  local avd_id
  avd_id="$(flutter emulators 2>/dev/null | awk -F'•' '/android/ {gsub(/ /, "", $1); print $1; exit}')"
  if [[ -z "$avd_id" ]]; then
    echo "No Android emulator was found."
    echo "Open Android Studio > More Actions > Virtual Device Manager and create one, then try again."
    exit 1
  fi
  echo "Starting the Android emulator ($avd_id)..."
  local emulator_bin
  emulator_bin="$(command -v emulator || true)"
  if [[ -z "$emulator_bin" && -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/emulator/emulator" ]]; then
    emulator_bin="$ANDROID_HOME/emulator/emulator"
  fi
  if [[ -n "$emulator_bin" ]]; then
    "$emulator_bin" -avd "$avd_id" -no-snapshot-load -no-boot-anim >/dev/null 2>&1 &
  else
    flutter emulators --launch "$avd_id" &
  fi
  echo "Waiting for it to finish booting (this can take a minute the first time)..."
  for _ in $(seq 1 90); do
    adb devices 2>/dev/null | grep -q "emulator-.*device$" && break
    sleep 2
  done
}

echo "What would you like to run CareConnect on?"
select choice in "iPhone (simulator)" "iPad / tablet (simulator)" "Android (emulator)" "Quit"; do
  case "$choice" in
    "iPhone (simulator)")
      udid="$(find_ios_udid '^ *iPhone [0-9]+ \(')"
      [[ -z "$udid" ]] && udid="$(find_ios_udid '^ *iPhone')"
      if [[ -z "$udid" ]]; then
        echo "No iPhone simulator found. Install one via Xcode > Settings > Platforms."
        exit 1
      fi
      boot_ios_simulator "$udid"
      flutter run -d "$udid"
      break
      ;;
    "iPad / tablet (simulator)")
      udid="$(find_ios_udid '^ *iPad\b')"
      if [[ -z "$udid" ]]; then
        echo "No iPad simulator found. Install one via Xcode > Settings > Platforms."
        exit 1
      fi
      boot_ios_simulator "$udid"
      flutter run -d "$udid"
      break
      ;;
    "Android (emulator)")
      boot_android_emulator
      device_id="$(adb devices 2>/dev/null | grep "emulator-.*device$" | head -1 | cut -f1)"
      flutter run -d "$device_id"
      break
      ;;
    "Quit")
      exit 0
      ;;
    *)
      echo "Please enter 1-4."
      ;;
  esac
done
