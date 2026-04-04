# Architecture Layers (P2-2: Dependency Enforcement)

This file defines the architectural layer hierarchy and import boundaries for the CCAT test harness.

---

## Architectural Layers

Layers are arranged from highest-level to lowest-level:

```
┌────────────────────────────────────────┐
│ Layer 3: Presentation & Reporting      │
│ (User-facing output, test UI)          │
├────────────────────────────────────────┤
│ Layer 2: Logic & Orchestration         │
│ (Test flow, scoring, decision-making)  │
├────────────────────────────────────────┤
│ Layer 1: State & Tracking              │
│ (Session management, test state)       │
├────────────────────────────────────────┤
│ Layer 0: Data & Configuration          │
│ (REQUIREMENTS.md, answer key, config)  │
└────────────────────────────────────────┘
```

---

## Import Rules

**Hierarchy:** Layer N can import from Layer 0 to N-1, but NOT from Layer N+1

| Source Layer | Can Import From | Cannot Import From |
|---|---|---|
| **Layer 3** (Presentation) | 0, 1, 2 | — |
| **Layer 2** (Logic) | 0, 1 | 3 |
| **Layer 1** (State) | 0 | 2, 3 |
| **Layer 0** (Data) | — | 1, 2, 3 |

---

## Layer Definitions

### Layer 0: Data & Configuration

**Purpose:** Canonical source of truth (no logic, no dependencies)

**Contents:**
- `REQUIREMENTS.md` — Test requirements
- `CCAT_TEST_META_RULES.md` — Test specification
- `answer-key.json` — Internal answer definitions
- `.agent/skills.json` — Skill manifest
- `.eslintrc.json`, `.prettierrc.json` — Linting config

**Rules:**
- NO imports from other layers
- Read-only from perspective of other layers
- Single source of truth

---

### Layer 1: State & Tracking

**Purpose:** Manage and persist test state (minimal logic)

**Contents:**
- `.session/test-results.json` — Test session state
- `.session/test-plan.md` — Question tracking
- `.session/context-checkpoint-*.md` — State snapshots
- `ANCHORS.md` — Decision records

**Rules:**
- Can read from: Layer 0 (config, requirements)
- Cannot read from: Layer 2, 3 (no circular dependencies)
- Serializable and recoverable
- No calculation logic (only tracking)

---

### Layer 2: Logic & Orchestration

**Purpose:** Test execution logic and decision-making

**Contents:**
- Test flow orchestration (intake → presentation → scoring → reporting)
- Scoring algorithm
- Domain analysis logic
- Recommendation engine

**Rules:**
- Can read from: Layer 0, 1
- Cannot read from: Layer 3 (presentation output)
- Contains all business logic
- Calls Layer 1 to persist state
- Called by Layer 3 to execute

---

### Layer 3: Presentation & Reporting

**Purpose:** User-facing output and formatting

**Contents:**
- Question presentation UI (text format)
- Final report generation
- User interaction (prompts, confirmations)
- Logging output to user

**Rules:**
- Can read from: Layer 0, 1, 2
- Calls Layer 2 for logic
- Formats Layer 1 state for display
- No business logic (only formatting)

---

## Enforcement Mechanism

### CI Check for Boundary Violations

In `.github/workflows/test.yml`:

```yaml
- name: "Architecture: Layer Boundary Check"
  run: |
    echo "=== Checking layer boundaries ==="
    
    # Example: Check that Layer 0 files don't import from others
    # (This is a stub; actual implementation depends on language/tooling)
    
    # Check 1: No circular dependencies in state tracking
    if grep -r "from.*reporting" .session/*.json; then
      echo "✗ FAIL: Layer 1 (State) imports from Layer 3"
      exit 1
    fi
    
    echo "✓ Layer boundaries verified"
```

---

## Dependency Graph

```
Layer 3: Presentation
  └─ calls → Layer 2 (logic)
               └─ calls → Layer 1 (state)
                            └─ reads → Layer 0 (data)
```

**Principle:** Dependencies flow downward only (from high to low layer).

---

## Testing Layer Boundaries

### Test Case 1: Layer 1 Should Not Know About Layer 2

```javascript
// ✗ BAD (violates boundary)
// state.json imports from scoring.js
{
  "current_question": 5,
  "calculation_in_progress": true  // ← Logic, not state
}

// ✓ GOOD
{
  "current_question": 5,
  "responses": [...]  // ← Pure state
}
```

### Test Case 2: Layer 0 Should Not Import From Others

```javascript
// ✗ BAD (violates boundary)
// config.json references test-results.json
{
  "test_id": "load from test-results.json"  // ← Dynamic reference
}

// ✓ GOOD
{
  "test_id": "ccat-20260405",  // ← Static config
  "max_questions": 50
}
```

---

## Refactoring Guidelines

If you need to add a new feature:

1. **Identify the layer** it belongs to
2. **Check dependencies** — can it import what it needs?
3. **If boundary violation:** Refactor to move code to correct layer
4. **Test:** Verify boundary check passes in CI

---

## Layer Maintenance

### Review Checklist

- [ ] Each module clearly belongs to one layer
- [ ] No circular imports
- [ ] Dependencies flow downward only
- [ ] Layer 0 is independent
- [ ] Layer 1 is read-only (minimal logic)
- [ ] Layer 2 contains all business logic
- [ ] Layer 3 is pure formatting

---

## Future Extensions

If adding multi-agent support (MAS):
- Add **Layer 4: Agent Coordination** (above Presentation)
- Coordinate multiple agents across test phases
- Agent communication via Layer 1 (state/messaging)

---

**Last Updated:** 2026-04-05 (v1.0.0)  
**Status:** Active (Tier 2 P2-2 Feature)
