#!/usr/bin/env bash
# Raysurfer post-execution upload hook.
# This is a lightweight placeholder that logs the hook trigger.
# The actual upload logic is handled by the raysurfer skill (Claude does it via curl).

set -euo pipefail

cat > /dev/null

echo "Raysurfer: upload hook triggered" >&2

exit 0
