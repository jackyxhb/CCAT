# Documentation Sync Schema (P3-2)

This file defines which documents must stay in sync and how to validate consistency.

---

## Files That Must Stay In Sync

### Critical Sync Points

| Document | Source of Truth | Sync Rule | Frequency |
|----------|---|---|---|
| **HE-SCOPE.md** | CCAT_TEST_META_RULES.md | Question count must match (50) | Every merge |
| **REQUIREMENTS.md** | P1-10 specification | REQ-001 through REQ-010 all present | Every merge |
| **AGENTS.md** | Actual agent definitions | Agent count and roles match reality | Every merge |
| **CLAUDE.md** | Latest harness version | Version tag is current | Every release |
| **CHANGELOG.md** | Automatic consolidation | Auto-updated by CI pipeline | Daily @ 2 AM |
| **test-plan.md** | Runtime test execution | Updated after each question | Every 10 Q |

---

## Sync Validation Rules

### Rule 1: Question Count Consistency

**Files to Check:** HE-SCOPE.md, CCAT_TEST_META_RULES.md, REQUIREMENTS.md

**Validation:**
```bash
# Extract and compare counts
SCOPE_COUNT=$(grep "Total Questions" HE-SCOPE.md | grep -o "[0-9]\+")
META_COUNT=$(grep "^##" CCAT_TEST_META_RULES.md | wc -l)
REQ_COUNT=$(grep "^| REQ-" REQUIREMENTS.md | wc -l)

if [ "$SCOPE_COUNT" != "$META_COUNT" ] || [ "$META_COUNT" != "50" ]; then
  echo "✗ FAIL: Question count mismatch"
  exit 1
fi
```

**CI Check:**
```yaml
- name: "Documentation Sync: Question Count"
  run: |
    EXPECTED=50
    ACTUAL=$(grep -c "^##" CCAT_TEST_META_RULES.md || echo "0")
    if [ "$ACTUAL" != "$EXPECTED" ]; then
      echo "✗ Question count mismatch: expected $EXPECTED, found $ACTUAL"
      exit 1
    fi
    echo "✓ Question count verified: $ACTUAL"
```

---

### Rule 2: Requirements Ledger Consistency

**Files to Check:** REQUIREMENTS.md, CLAUDE.md

**Validation:**
```bash
# Verify all REQ-001 through REQ-010 present
for i in {1..10}; do
  REQ=$(printf "REQ-%03d" $i)
  if ! grep -q "$REQ" REQUIREMENTS.md; then
    echo "✗ FAIL: Missing $REQ in REQUIREMENTS.md"
    exit 1
  fi
done
echo "✓ All 10 requirements present"
```

**CI Check:**
```yaml
- name: "Documentation Sync: Requirements Ledger"
  run: |
    for i in {1..10}; do
      REQ=$(printf "REQ-%03d" $i)
      if ! grep -q "$REQ" REQUIREMENTS.md; then
        echo "✗ Missing $REQ"
        exit 1
      fi
    done
    echo "✓ All requirements present"
```

---

### Rule 3: Agent Definition Consistency

**Files to Check:** AGENTS.md, actual agent configuration

**Validation:**
```bash
# Verify primary agent defined
if grep -q "CCAT Test Orchestrator" AGENTS.md; then
  echo "✓ Primary agent defined"
else
  echo "✗ FAIL: Agent definition missing"
  exit 1
fi
```

**CI Check:**
```yaml
- name: "Documentation Sync: Agent Definitions"
  run: |
    if ! grep -q "CCAT Test Orchestrator" AGENTS.md; then
      echo "✗ Agent definition incomplete"
      exit 1
    fi
    echo "✓ Agent definitions verified"
```

---

### Rule 4: Harness Version Consistency

**Files to Check:** CLAUDE.md, HE-EXECUTION-SUMMARY.md, CHANGELOG.md

**Validation:**
```bash
# Extract version from CLAUDE.md
VERSION=$(grep "Last Updated" CLAUDE.md | tail -1)
echo "✓ CLAUDE.md version: $VERSION"

# Verify CHANGELOG has matching version
if grep -q "$(echo $VERSION | cut -d' ' -f3)" CHANGELOG.md; then
  echo "✓ CHANGELOG matches version"
else
  echo "⚠ CHANGELOG may need update"
fi
```

---

## Sync Enforcement in CI

Add to `.github/workflows/test.yml`:

```yaml
- name: "Documentation Sync: Complete Validation"
  run: |
    echo "=== Validating Documentation Consistency ==="

    # Test 1: Question count
    EXPECTED_QUESTIONS=50
    if grep -q "$EXPECTED_QUESTIONS" HE-SCOPE.md; then
      echo "✓ Question count matches (50)"
    else
      echo "✗ FAIL: Question count mismatch"
      exit 1
    fi

    # Test 2: Requirements ledger
    REQ_COUNT=$(grep -c "^| REQ-" REQUIREMENTS.md || echo "0")
    if [ "$REQ_COUNT" -ge 10 ]; then
      echo "✓ Requirements ledger complete ($REQ_COUNT+ reqs)"
    else
      echo "✗ FAIL: Requirements incomplete"
      exit 1
    fi

    # Test 3: Agent definitions
    if grep -q "CCAT Test Orchestrator" AGENTS.md; then
      echo "✓ Agent definitions present"
    else
      echo "✗ FAIL: Agent definition missing"
      exit 1
    fi

    # Test 4: CLAUDE.md completeness
    REQUIRED_SECTIONS=("Test Execution Rules" "Socratic Questioning" "Escalation Policies")
    for section in "${REQUIRED_SECTIONS[@]}"; do
      if grep -q "$section" CLAUDE.md; then
        echo "✓ Found section: $section"
      else
        echo "✗ FAIL: Missing section: $section"
        exit 1
      fi
    done

    echo ""
    echo "✓ All documentation consistency checks passed"
```

---

## Sync Automation (Consolidation Loop)

The `.github/workflows/consolidate.yml` pipeline automatically:

1. Extracts live question count from code
2. Updates HE-SCOPE.md if mismatch detected
3. Verifies REQUIREMENTS.md completeness
4. Validates AGENTS.md against agent definitions
5. Accumulates CHANGELOG entries
6. Commits sync changes (if any)

**Frequency:** Daily @ 2 AM UTC + on every push

---

## Stale Documentation Detection

**Definition:** Doc is stale if modified > 7 days ago AND source changed since

**Detection:**
```bash
# Find docs older than 7 days
find . -name "*.md" -mtime +7

# Check if source files are newer
if [ source -nt doc ]; then
  echo "⚠ $doc is stale; source changed"
fi
```

**CI Check:**
```yaml
- name: "Documentation Sync: Stale Detection"
  run: |
    # Find markdown files modified > 7 days ago
    STALE=$(find . -name "*.md" -mtime +7 | head -5)
    if [ ! -z "$STALE" ]; then
      echo "⚠ Potentially stale docs (> 7 days old):"
      echo "$STALE"
      # Note: Warning only; docs are stale but CI doesn't fail
    fi
```

---

## Documentation Update Workflow

When documentation needs updating:

1. **Identify stale doc** — Failed sync check identifies which doc is out of sync
2. **Update doc** — Edit the document to match source of truth
3. **Run sync check** — Verify fix with `npm run sync-check` or CI
4. **Commit** — Commit with message: `docs: sync [filename] with source`

---

## References

- **consolidate.yml** — Automated sync pipeline
- **.github/workflows/test.yml** — Sync validation checks
- **HE-SCOPE.md** — System counts (updated by consolidation)
- **CHANGELOG.md** — Release notes (auto-updated)

---

**Last Updated:** 2026-04-05 (v1.0.0)  
**Status:** Active (Tier 2 P3-2 Feature)
