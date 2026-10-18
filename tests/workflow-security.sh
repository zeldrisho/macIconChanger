#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANDIDATE="$REPO_ROOT/.github/workflows/release-candidate.yml"
PUBLISH="$REPO_ROOT/.github/workflows/publish-release.yml"
CODEQL="$REPO_ROOT/.github/workflows/codeql.yml"

# Dispatch inputs must be passed to the shell as environment values, never
# interpolated into the run script's source text.
python3 - "$CANDIDATE" "$PUBLISH" <<'PY'
from pathlib import Path
import sys

candidate = Path(sys.argv[1]).read_text()
publish = Path(sys.argv[2]).read_text()
checks = {
    "release version input is passed via env": (
        "VERSION_INPUT: ${{ inputs.version }}" in candidate
        and 'VERSION="${{ inputs.version }}"' not in candidate
    ),
    "release approval input is passed via env": (
        "APPROVAL_INPUT: ${{ inputs.approval }}" in publish
        and '"${{ inputs.approval }}"' not in publish
    ),
}
for message, passed in checks.items():
    print(f"{'PASS' if passed else 'FAIL'}: {message}")
if not all(checks.values()):
    raise SystemExit(1)
PY

for expected in \
    'languages: python' \
    'languages: swift' \
    'build-mode: manual' \
    '-scheme IconChanger'; do
    grep -Fq -- "$expected" "$CODEQL" || {
        echo "FAIL: CodeQL workflow is missing: $expected" >&2
        exit 1
    }
done

echo "PASS: CodeQL explicitly analyzes Python and manually builds Swift"
