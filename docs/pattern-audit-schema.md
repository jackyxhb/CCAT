# Pattern Audit Schema (P3-3)

**Feature:** P3-3 (Pattern Auditing)  
**Tier:** Tier 3 (Advanced)  
**Purpose:** Detect and prevent code entropy through automated pattern analysis  
**Status:** Operational

---

## Overview

Pattern auditing is the automated detection of code smells, architectural issues, and entropy indicators that accumulate over time. This schema defines what patterns to look for and how to handle them.

---

## Pattern Categories

### 1. Dead Code Patterns

**Definition:** Code that exists in the codebase but is never executed or referenced.

#### Dead Code Indicators

| Pattern | Description | Detection | Action |
|---------|-------------|-----------|--------|
| **Unused Functions** | Function defined but never called | Search for `function foo()` + grep for `foo()` | Flag for review or removal |
| **Unused Variables** | Variable declared but never read | Search for `const x =` + grep for `x` | Flag for review |
| **Unused Imports** | Module imported but not used in code | `import X from Y` without reference to X | Remove import |
| **Unreachable Code** | Code after `return` statement | Scan for patterns like `return; code_here` | Flag for removal |
| **Dead Comments** | TODO/FIXME older than 30 days | Check comment timestamps vs modification date | Escalate to owner or archive |

#### Detection Example

```bash
# Find unused functions in .agent/
grep -r "function [a-zA-Z_][a-zA-Z0-9_]*" .agent/ | \
  awk '{print $2}' | \
  while read func; do
    if ! grep -q "$func()" .agent/; then
      echo "Unused function: $func"
    fi
  done
```

#### Cleanup Actions

1. **Automatic Removal** (safe):
   - Unreachable code (dead code after return)
   - Unused imports
   - Duplicate import statements

2. **Manual Review** (needs human):
   - Unused functions (might be entry points)
   - Unused variables (might be intentional constants)
   - TODO/FIXME comments (decide on resolution)

---

### 2. Circular Dependencies

**Definition:** Two or more modules depend on each other, creating a dependency cycle.

#### Circular Dependency Patterns

| Pattern | Description | Example | Risk |
|---------|-------------|---------|------|
| **Direct Cycle** | A imports B, B imports A | `agent-a.js` imports `agent-b.js` which imports `agent-a.js` | High - causes load errors |
| **Indirect Cycle** | A → B → C → A | Supervisor imports Orchestrator, Orchestrator imports Coordinator, Coordinator imports Supervisor | Medium - breaks modularity |
| **Self-Reference** | Module imports itself | `foo.js: import foo from './foo.js'` | Critical - load failure |
| **Transitive Cycle** | Module imports package that re-exports itself | Node modules edge case | Low - usually handled by runtime |

#### Detection Example

```bash
# Check for circular imports in agent files
for file in .agent/**/*.md; do
  # Extract imports
  imports=$(grep "^import\|require(" "$file")
  
  for import in $imports; do
    # Check if imported file imports back
    imported_file=$(echo $import | awk '{print $NF}' | sed 's/[";]//g')
    if grep -q "$(basename $file .md)" "$imported_file"; then
      echo "Circular dependency: $file <-> $imported_file"
    fi
  done
done
```

#### Resolution Strategy

1. **Break the cycle** by introducing intermediary module
2. **Extract shared code** to neutral module
3. **Reverse dependency** (A depends on B, not vice versa)
4. **Document as acceptable** (if intentional pattern)

---

### 3. Code Duplication

**Definition:** Identical or highly similar code blocks appearing in multiple places.

#### Duplication Patterns

| Pattern | Threshold | Action |
|---------|-----------|--------|
| **Exact Duplication** | 100% match, > 20 lines | Extract to shared function |
| **High Similarity** | 90%+ match, > 20 lines | Refactor into parameterized function |
| **Similar Logic** | Same structure, different vars | Consider shared implementation |
| **Copy-Paste Errors** | Duplication with inconsistencies | Flag as potential bug |

#### Detection Example

```bash
# Find duplicate code blocks (> 20 lines)
find . -name "*.md" -o -name "*.js" | xargs cat | \
  awk 'NR > 20 { print prev; prev = $0; next } { prev = prev "\n" $0 }' | \
  sort | uniq -d | wc -l

# Report duplicated lines
# If count > 0: duplication detected
```

#### Refactoring Strategy

1. **Identify** — Find duplicate blocks
2. **Extract** — Create shared function/component
3. **Replace** — Update all callsites to use shared version
4. **Test** — Verify behavior unchanged
5. **Cleanup** — Remove old duplicates

---

### 4. Architecture Violations

**Definition:** Code that violates the declared 4-layer architecture.

#### Layer Violations

| Violation | Definition | Example | Fix |
|-----------|-----------|---------|-----|
| **Circular Layer Import** | Higher layer imports lower | View layer imports Data layer | Rearrange imports |
| **Layer Skipping** | Skip intermediate layer | Presentation directly to Database | Add intermediate layer |
| **Cross-Layer Reference** | Layer references sibling | One domain module imports another | Use facade |

#### 4-Layer Model (from architecture-layers.md)

```
Layer 1: Presentation (CLI, Web UI, API endpoints)
  ↓ may import
Layer 2: Logic (Business logic, decision trees, algorithms)
  ↓ may import
Layer 3: State (Session management, context, memory)
  ↓ may import
Layer 4: Data (Files, database, external APIs, persistence)
```

**Valid Imports:**
- Layer 1 → Layer 2, 3, 4
- Layer 2 → Layer 3, 4
- Layer 3 → Layer 4
- Layer 4 → (nothing)

**Invalid Imports:**
- Layer 4 → Layer 1, 2, 3 (NEVER import upward)
- Layer 2 → Layer 1 (NEVER import upward)
- Any layer → sibling layer (except through facade)

#### Detection Example

```bash
# Check import direction in .agent/
for file in .agent/**/*.js; do
  layer=$(detect_layer "$file")  # Determine which layer file belongs to
  imports=$(grep "^import" "$file")
  
  for import in $imports; do
    imported_file=$(resolve_import "$import")
    imported_layer=$(detect_layer "$imported_file")
    
    if ! is_valid_import "$layer" "$imported_layer"; then
      echo "VIOLATION: $file (Layer $layer) imports $imported_file (Layer $imported_layer)"
    fi
  done
done
```

---

### 5. Documentation Drift

**Definition:** Documentation is out of sync with code.

#### Drift Indicators

| Indicator | Detection | Action |
|-----------|-----------|--------|
| **Version Mismatch** | Doc version ≠ Code version | Update doc to match code |
| **Feature List Stale** | Listed features not in code | Remove from list |
| **Outdated Examples** | Examples don't match current API | Update examples |
| **Broken Links** | Links to deleted files | Remove or update links |
| **Unsynced Counts** | File counts don't match reality | Auto-update counts |

#### Sync Rules (from sync-schema.md)

Critical files that must stay synchronized:
- HE-SCOPE.md (question count)
- REQUIREMENTS.md (requirement list)
- AGENTS.md (agent definitions)
- CLAUDE.md (version tags)
- CHANGELOG.md (auto-updated)

---

## Audit Report Format

### Report Structure

```markdown
# Pattern Audit Report
**Date:** 2026-04-05T02:00:00Z

## Summary
- Dead Code: 0 issues
- Circular Dependencies: 0 issues  
- Code Duplication: 0 blocks
- Architecture Violations: 0 violations
- Documentation Drift: 0 items
- **Overall Status:** HEALTHY

## Dead Code Details
(list any dead code found)

## Circular Dependencies
(list any cycles detected)

## Duplication Analysis
(list duplicate code blocks)

## Architecture Issues
(list any import violations)

## Documentation Issues
(list any drift detected)

## Metrics
- Lines of Dead Code: 0
- Circular Dependency Chains: 0
- Duplicate Block Count: 0
- Layer Violations: 0
- Doc Staleness: 0%
```

### Report Storage

- **Location:** `.session/pattern-audit-[YYYY-MM-DD].md`
- **Frequency:** Weekly (Sundays 2 AM UTC) + on-push
- **Retention:** 30 days (cleaned by cleanup.yml)
- **Tracking:** `pattern-metrics-[YYYY-MM-DD].json` for metrics

---

## Automation & Integration

### CI Pipeline Integration

Pattern audit runs as part of `.github/workflows/pattern-audit.yml`:

1. **Trigger:** Weekly schedule + on-push + manual
2. **Execution:** All pattern checks
3. **Report:** Generate markdown + JSON metrics
4. **Storage:** Save to `.session/pattern-audit-*.md`
5. **Commit:** Auto-commit report if changes detected

### Consolidation Loop Integration

The `.github/workflows/consolidate.yml` pipeline includes:

1. **Daily execution** (consolidation runs daily)
2. **Pattern aggregation** (collect all weekly audits)
3. **Trend analysis** (track metrics over time)
4. **Alert generation** (if metrics degrade)

**Metrics Tracked:**
```json
{
  "date": "2026-04-05",
  "dead_code_count": 0,
  "circular_deps": 0,
  "duplication_blocks": 0,
  "architecture_violations": 0,
  "doc_drift_items": 0,
  "trend": "improving"
}
```

### Cleanup Integration

Stale pattern audit reports cleaned by `.github/workflows/cleanup.yml`:
- Keep reports < 30 days old
- Archive older reports to `.session/archive/`
- Maintain 30-day rolling window

---

## Thresholds & Alerting

### Health Thresholds

| Metric | Green (OK) | Yellow (Warning) | Red (Critical) |
|--------|-----------|-----------------|-----------------|
| **Dead Code Lines** | 0-5 | 5-20 | > 20 |
| **Circular Dependencies** | 0 | 1 | > 1 |
| **Duplication Blocks** | 0-2 | 3-5 | > 5 |
| **Architecture Violations** | 0 | 1-2 | > 2 |
| **Doc Drift Items** | 0-1 | 2-3 | > 3 |

### Alerting Strategy

- **Green:** No action needed
- **Yellow:** Review findings; create issue if needed
- **Red:** Auto-escalate; block merge if critical

---

## Prevention Best Practices

### Code Review Checklist

Before merging PRs, verify:
- [ ] No new dead code introduced
- [ ] No new circular dependencies
- [ ] No code duplication added
- [ ] Layer boundaries respected
- [ ] Documentation updated

### Naming Conventions

To prevent drift:
- Use consistent names (file names, function names, agent IDs)
- Avoid renaming without updating all references
- Keep counts in comments near definitions

### Automation Benefits

✅ **Prevents Accumulation** — Catches issues early  
✅ **Continuous Monitoring** — Detects drift automatically  
✅ **Trend Analysis** — Shows system health over time  
✅ **Proactive Maintenance** — Fixes before they become problems  
✅ **Compliance Audit Trail** — Full history of pattern audits

---

## References

- **pattern-audit.yml** — GitHub workflow implementation
- **cleanup.yml** — Stale report cleanup
- **consolidate.yml** — Metrics aggregation
- **architecture-layers.md** — 4-layer model definition
- **sync-schema.md** — Documentation sync rules

---

**Last Updated:** 2026-04-05 (v1.0.0)  
**Status:** ✅ Operational (Tier 3 P3-3)
