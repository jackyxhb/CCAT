#!/bin/bash
# save-session.sh — Checkpoint test session state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "save-session.sh"
echo "========================================="

# Check if test session exists
if [ ! -f .session/test-results.json ]; then
  echo "✗ No active test session found"
  echo "  (Expected: .session/test-results.json)"
  exit 1
fi

# Step 1: Extract current question
echo ""
echo "[1/2] Creating session checkpoint..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
QUESTION=$(jq '.current_question // 0' .session/test-results.json 2>/dev/null || echo "unknown")

echo "  - Current question: Q$QUESTION"
echo "  - Checkpoint time: $TIMESTAMP"

# Update session file with checkpoint timestamp
jq --arg ts "$TIMESTAMP" '.last_checkpoint = $ts' .session/test-results.json > .session/test-results.tmp
if [ $? -eq 0 ]; then
  mv .session/test-results.tmp .session/test-results.json
  echo "  ✓ Session state updated"
else
  echo "  ✗ Failed to update session state"
  exit 1
fi

# Step 2: Commit checkpoint
echo ""
echo "[2/2] Committing checkpoint..."

git add .session/test-results.json

if ! git diff-index --quiet HEAD .session/test-results.json; then
  git commit -m "checkpoint: test state at question Q${QUESTION} [$TIMESTAMP]" 2>/dev/null || true
  echo "  ✓ Session checkpoint committed"
else
  echo "  ℹ No changes to commit"
fi

echo ""
echo "========================================="
echo "✓ Session checkpoint saved"
echo "  Question: Q$QUESTION"
echo "  Time: $TIMESTAMP"
echo "========================================="
exit 0
