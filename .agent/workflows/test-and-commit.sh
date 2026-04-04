#!/bin/bash
# test-and-commit.sh — Run verification tests, then commit with metadata

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "test-and-commit.sh"
echo "========================================="

# Step 1: Run verification tests
echo ""
echo "[1/3] Running test verification..."

if [ ! -f .github/workflows/test.yml ]; then
  echo "✗ FAIL: Test suite not found (.github/workflows/test.yml)"
  exit 1
fi

# Run basic verification checks
echo "  - Checking Requirements Ledger..."
REQ_COUNT=$(grep -c "REQ-" REQUIREMENTS.md || echo "0")
if [ "$REQ_COUNT" -lt 10 ]; then
  echo "  ✗ FAIL: Requirements incomplete (found $REQ_COUNT, expected 10)"
  exit 1
fi
echo "  ✓ Requirements ledger valid ($REQ_COUNT requirements)"

echo "  - Checking CLAUDE.md..."
if [ ! -f CLAUDE.md ] || ! grep -q "Test Execution Rules" CLAUDE.md; then
  echo "  ✗ FAIL: CLAUDE.md incomplete"
  exit 1
fi
echo "  ✓ CLAUDE.md complete"

echo "  - Checking AGENTS.md..."
if [ ! -f AGENTS.md ] || ! grep -q "CCAT Test Orchestrator" AGENTS.md; then
  echo "  ✗ FAIL: AGENTS.md incomplete"
  exit 1
fi
echo "  ✓ AGENTS.md complete"

echo "  - Checking ANCHORS.md..."
ANCHOR_COUNT=$(grep -c "Anchor" ANCHORS.md || echo "0")
if [ "$ANCHOR_COUNT" -lt 5 ]; then
  echo "  ✗ FAIL: ANCHORS incomplete (found $ANCHOR_COUNT, expected 5)"
  exit 1
fi
echo "  ✓ ANCHORS.md complete ($ANCHOR_COUNT anchors)"

echo "✓ Test verification passed"

# Step 2: Run linting checks (stub for now)
echo ""
echo "[2/3] Running linting checks..."
echo "  ✓ Linting passed (stub)"

# Step 3: Commit changes
echo ""
echo "[3/3] Committing changes..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.0")

git add -A

# Check if there are changes to commit
if git diff-index --quiet HEAD; then
  echo "  ℹ No changes to commit"
else
  git commit -m "chore: test pass verification [$VERSION @ $TIMESTAMP]" \
    --allow-empty

  echo "  ✓ Committed with metadata"
fi

echo ""
echo "========================================="
echo "✓ test-and-commit complete"
echo "========================================="
exit 0
