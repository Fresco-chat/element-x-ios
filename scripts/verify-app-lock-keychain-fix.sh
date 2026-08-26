#!/usr/bin/env bash
# Verifies App Lock does not enable when keychain read fails.
# Run on macOS with Xcode from the element-x-ios repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_PATH="${CURSOR_DEBUG_LOG_PATH:-$ROOT/../.cursor/debug-83240d.log}"

cd "$ROOT"
mkdir -p test_output "$(dirname "$LOG_PATH")"
export CURSOR_DEBUG_LOG_PATH="$LOG_PATH"

echo "Running AppLockService keychain-failure unit test..."
swift run -q tools ci run-tests \
  --scheme UnitTests \
  --test-name AppLockServiceTests/keychainAccessErrorDoesNotEnableAppLock \
  --retries 2

python3 - <<PY
import json, os, time
payload = {
  "sessionId": "83240d",
  "runId": "post-fix",
  "hypothesisId": "H1",
  "location": "scripts/verify-app-lock-keychain-fix.sh",
  "message": "AppLockServiceTests/keychainAccessErrorDoesNotEnableAppLock passed locally",
  "data": {},
  "timestamp": int(time.time() * 1000),
}
with open(os.environ["CURSOR_DEBUG_LOG_PATH"], "a", encoding="utf-8") as f:
  f.write(json.dumps(payload) + "\n")
print(f"Wrote verification log to {os.environ['CURSOR_DEBUG_LOG_PATH']}")
PY
