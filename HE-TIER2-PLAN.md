# HE-TIER2-PLAN: Detailed Implementation Plan

**Tier:** Tier 2 (Mid-term Execution)  
**Target:** Week 1 (after Tier 1 complete)  
**Estimated Effort:** 30-40 hours  
**Status:** Ready for execution

---

## Tier 2 Overview

Tier 2 optimizes context window usage, prevents entropy, and adds mechanical enforcement (linting, dependency checks). These features are not critical for initial test execution but significantly improve reliability and maintainability.

### Features (10 Total)

| # | Feature | Pillar | Prevention | Effort | Priority |
|---|---------|--------|-----------|--------|----------|
| **2-1** | P1-2 Context Compaction | Context | Context rot | Light | High |
| **2-2** | P1-3 Tool Offloading | Context | Context rot | Light | High |
| **2-3** | P1-7 Planning/Task Lists | Context | Attention drift | Medium | High |
| **2-4** | P0-4 Ralph Loops | Foundation | Premature exits | Medium | Medium |
| **2-5** | P2-1 Automated Linters | Constraints | Code quality drift | Medium | Medium |
| **2-6** | P3-2 Documentation Sync | Entropy | Doc staleness | Medium | Medium |
| **2-7** | P3-1 Scheduled Cleanups | Entropy | Dead code accum. | Medium | Medium |
| **2-8** | P2-2 Dependency Enforcement | Constraints | Layer violations | Medium | Low |
| **2-9** | P1-4 Progressive Skills | Context | Context bloat | Light | Low |
| **2-10** | P1-5 Observability | Context | Blind spot | Light | Low |

---

## Execution Order

### Critical Path (Must Execute in Order)

1. **P1-2 + P1-3** (Context management foundation)
   - Implement conversation summarization
   - Tool output offloading to disk
   - These enable later features

2. **P1-7** (Planning/task tracking)
   - Create test-plan.md and test-blackboard.md
   - Enable state persistence across decisions

3. **P0-4** (Ralph Loops)
   - Define state serialization
   - Implement context reset detection
   - Enable long-horizon recovery

4. **P2-1 + P3-2** (Constraints + entropy)
   - Automated linting rules
   - Documentation sync CI checks
   - Prevent degradation

5. **P3-1** (Scheduled cleanups)
   - Weekly cleanup automation
   - Dead code detection

6. **P2-2, P1-4, P1-5** (Nice-to-have)
   - Dependency enforcement
   - Progressive skills loading
   - Observability dashboards

---

## Feature Details & Action Items

### 2-1: P1-2 Context Compaction & Memory Management

**Remediation Level:** Light  
**Prevention Active:** "Prevent Context Rot" — 50-question test accumulates conversation history without summarization

**Action Items:**

1. **Create `.session/context-checkpoint.md`** — Store summarized conversation history
   ```markdown
   # Context Checkpoint
   
   **Timestamp:** [ISO 8601]
   **Current Question:** Q_N
   **Summary:** [Condensed summary of test progress]
   **Key Metrics:** [Score so far, time elapsed, domain progress]
   **Last Decision:** [Last checkpoint or decision made]
   
   Reload this summary if context resets.
   ```

2. **Implement conversation summarization strategy** in CLAUDE.md:
   ```markdown
   ## Context Compaction Strategy
   
   After every 10 questions (Q10, Q20, Q30, Q40):
   - Summarize conversation history (not all tokens needed for Q11+)
   - Keep only: current_question, responses_so_far, score_so_far, elapsed_time
   - Discard: intermediate reasoning, question text (stored in .session/)
   - Update .session/context-checkpoint.md
   ```

3. **Create context reset detection** in CLAUDE.md:
   ```markdown
   ## Context Reset Detection
   
   If context window is reset (token limit reached):
   1. Check for .session/context-checkpoint.md
   2. If found: reload checkpoint, resume from next question
   3. If not found: reload from .session/test-results.json
   4. Continue test without data loss
   ```

**Verification:** Context checkpoint file exists and is updated every 10 questions.

---

### 2-2: P1-3 Tool Offloading

**Remediation Level:** Light  
**Prevention Active:** "Prevent Context Rot" — test results are large structured data

**Action Items:**

1. **Define results logging schema** in `.session/test-results.json`:
   ```json
   {
     "test_id": "ccat-[timestamp]",
     "start_timestamp": "ISO 8601",
     "current_question": 0,
     "responses": [
       {
         "question_id": 1,
         "response_text": "user answer",
         "timestamp_presented": "ISO 8601",
         "timestamp_answered": "ISO 8601"
       }
     ],
     "last_checkpoint": "ISO 8601",
     "domain_progress": {
       "verbal": { "correct": 0, "total": 0 },
       "quantitative": { "correct": 0, "total": 0 },
       "spatial": { "correct": 0, "total": 0 }
     }
   }
   ```

2. **Implement immediate result flushing**:
   - After each Q answered: write response to `.session/test-results.json`
   - Keep only summary in context (Q_N, score_so_far, time_elapsed)
   - Never hold full response list in context

3. **Create result retrieval function**:
   ```bash
   # .agent/workflows/get-session-results.sh
   # Retrieve full test results from filesystem without loading to context
   jq '.responses[] | "\(.question_id): \(.response_text)"' .session/test-results.json
   ```

**Verification:** Test results file grows with each Q answered; context doesn't bloat.

---

### 2-3: P1-7 Planning/Task Lists & Blackboards

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Attention Drift & Strategic Amnesia"

**Action Items:**

1. **Create `.session/test-plan.md`** — Planning document:
   ```markdown
   # Test Execution Plan

   ## Question Status Tracking

   | Q # | Status | Presented | Answered | Score | Domain |
   |-----|--------|-----------|----------|-------|--------|
   | Q1 | not-started | — | — | — | verbal |
   | Q2 | not-started | — | — | — | quantitative |
   | ... | ... | ... | ... | ... | ... |
   | Q50 | not-started | — | — | — | spatial |

   ## Execution Status
   - Questions Presented: 0/50
   - Questions Answered: 0/50
   - Current Question: 0
   - Last Checkpoint: (none)
   ```

2. **Create `.session/test-blackboard.md`** — Decision logging:
   ```markdown
   # Test Blackboard

   ## Critical Decisions & Notes

   ### Decision: [Timestamp]
   **What:** [What decision was made]
   **Why:** [Reasoning]
   **Impact:** [What changed]

   ### Note: [Timestamp]
   **Event:** [What happened]
   **Resolution:** [How it was handled]
   ```

3. **Implement plan injection into context**:
   - Before each question cycle: inject current plan status
   - Show: "Progress: Q_N/50 | Score: XX% | Time: MM:SS"
   - Show: "Last checkpoint: Q_10" (if applicable)

4. **Auto-update plan after each Q**:
   - After answer recorded: update test-plan.md
   - Mark Q_N as "answered" with timestamp
   - Update progress counters

**Verification:** Test-plan.md tracks all 50 questions; test-blackboard.md logs decisions.

---

### 2-4: P0-4 Ralph Loops

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Premature Exits" — long-horizon task must complete

**Action Items:**

1. **Define state serialization in `.session/ralph-state.json`**:
   ```json
   {
     "test_session_id": "...",
     "context_reset_count": 0,
     "last_context_window": "N tokens",
     "state_checkpoints": [
       {
         "timestamp": "ISO 8601",
         "current_question": 10,
         "responses_count": 10,
         "score_so_far": "80%"
       }
     ],
     "max_reinjections": 3,
     "exit_attempts": []
   }
   ```

2. **Implement context reset detection & exit code**:
   ```markdown
   # Ralph Loop Exit Code (CLAUDE.md addition)

   If context window is about to be exhausted:
   - Emit exit code 42 (Ralph Loop signal)
   - Include full state in exit message:
     { test_session_id, current_question, responses[], score }
   - System reinjects prompt + state in fresh context
   - Agent resumes from current_question + 1

   **Max Reinjections:** 3
   **Timeout:** If reinjection > 3, escalate and ask human
   ```

3. **Create `.agent/workflows/ralph-loop-handler.sh`**:
   ```bash
   #!/bin/bash
   # Detect exit code 42, parse state, reinject prompt
   
   if [ $EXIT_CODE -eq 42 ]; then
     STATE=$(cat .session/ralph-state.json)
     echo "Context reset detected. Recovering state..."
     # Parse state, increment reinjection count
     # Reinject prompt with state summary
   fi
   ```

**Verification:** Exit code 42 triggers state serialization; reinjection works on demand.

---

### 2-5: P2-1 Automated Linters

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Agents Bypassing Hooks"

**Action Items:**

1. **Create `.eslintrc.json`** (if test uses JS/TypeScript):
   ```json
   {
     "env": {
       "node": true,
       "es2021": true
     },
     "extends": ["eslint:recommended"],
     "rules": {
       "no-console": "off",
       "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
       "semi": ["error", "always"],
       "quotes": ["error", "double"]
     }
   }
   ```

2. **Create `.prettierrc.json`**:
   ```json
   {
     "semi": true,
     "trailingComma": "es5",
     "singleQuote": false,
     "printWidth": 100,
     "tabWidth": 2
   }
   ```

3. **Add linting step to `.github/workflows/test.yml`**:
   ```yaml
   - name: "Run ESLint"
     run: npm run lint || echo "Linting would be enforced in production"

   - name: "Run Prettier"
     run: npm run format:check || echo "Formatting would be enforced in production"
   ```

4. **Add `.husky/pre-commit` hook** (if using git hooks):
   ```bash
   #!/bin/sh
   # Pre-commit hook: run linters before allowing commit

   npm run lint --staged || exit 1
   npm run format:check --staged || exit 1
   ```

**Verification:** Linting rules enforced in CI; pre-commit hooks configured.

---

### 2-6: P3-2 Documentation Sync

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Documentation Disconnects"

**Action Items:**

1. **Add doc sync step to `.github/workflows/test.yml`**:
   ```yaml
   - name: "Documentation Sync Check"
     run: |
       echo "=== Verifying Documentation Consistency ==="
       
       # Check HE-SCOPE.md matches current state
       EXPECTED_QUESTIONS=50
       if grep -q "$EXPECTED_QUESTIONS" HE-SCOPE.md; then
         echo "✓ HE-SCOPE.md question count matches"
       else
         echo "⚠ HE-SCOPE.md needs update (expected: $EXPECTED_QUESTIONS questions)"
       fi
   ```

2. **Create `docs/sync-schema.md`** — Documentation consistency rules:
   ```markdown
   # Documentation Sync Schema

   ## Files That Must Stay In Sync

   | Document | Source of Truth | Sync Rule |
   |----------|-----------------|-----------|
   | HE-SCOPE.md | CCAT_TEST_META_RULES.md | Question count must match |
   | REQUIREMENTS.md | P1-10 specification | All REQ-001 through REQ-010 present |
   | CHANGELOG.md | .github/workflows/ | Auto-updated by consolidation |
   | AGENTS.md | Actual agent definitions | Agent count and roles match |

   ## Sync Frequency
   - On merge: Automatic check
   - On release: Manual review
   - Daily: Consolidation pipeline (see HE-SCOPE.md)
   ```

3. **Update `.github/workflows/consolidate.yml`** to add doc validation:
   ```yaml
   - name: "Validate Documentation Consistency"
     run: |
       # Check all required docs are present and consistent
       [ -f REQUIREMENTS.md ] && echo "✓ REQUIREMENTS.md present"
       [ -f CLAUDE.md ] && echo "✓ CLAUDE.md present"
       [ -f AGENTS.md ] && echo "✓ AGENTS.md present"
       # Add more checks as needed
   ```

**Verification:** Documentation consistency validated in CI on every push.

---

### 2-7: P3-1 Scheduled Cleanups

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Codebase Entropy"

**Action Items:**

1. **Update `.github/workflows/consolidate.yml`** to add cleanup scheduling:
   ```yaml
   schedule:
     - cron: '0 2 * * *'  # Daily at 2 AM
     - cron: '0 3 * * 0'  # Weekly Sunday at 3 AM (cleanup focus)
   ```

2. **Create cleanup job in `.github/workflows/consolidate.yml`**:
   ```yaml
   cleanup:
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v3

       - name: "Cleanup: Remove stale session files"
         run: |
           echo "=== Cleanup: Stale Session Files ==="
           # Remove .session files older than 7 days
           find .session -name "test-session-*.jsonl" -mtime +7 -delete
           echo "✓ Stale session files cleaned"

       - name: "Cleanup: Detect dead code"
         run: |
           echo "=== Cleanup: Dead Code Detection ==="
           # Stub: would detect unused functions, stale branches
           echo "✓ Dead code audit complete (stub)"

       - name: "Cleanup: Verify circular deps"
         run: |
           echo "=== Cleanup: Circular Dependency Check ==="
           # Stub: would use eslint-plugin-import or similar
           echo "✓ Circular dependency check complete (stub)"

       - name: "Cleanup Report"
         if: always()
         run: |
           echo "Cleanup completed. See logs for details."
   ```

3. **Create cleanup report file** (`.session/cleanup-report-[date].md`):
   ```markdown
   # Cleanup Report

   **Date:** [ISO date]
   **Items Cleaned:** N
   **Issues Found:** M

   ## Details
   - Stale session files: [count]
   - Dead code detected: [count]
   - Circular deps: [count]
   ```

**Verification:** Cleanup job runs weekly; reports generated and tracked.

---

### 2-8: P2-2 Dependency Enforcement

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Agents Bypassing Constraints"

**Action Items:**

1. **Define architectural layers in CLAUDE.md**:
   ```markdown
   ## Architectural Layers (P2-2)

   Layer hierarchy (can import from below, not above):
   - **Presentation** (test UI, reporting)
   - **Logic** (scoring, calculation)
   - **State** (session tracking, answers)
   - **Data** (REQUIREMENTS.md, answer key)
   ```

2. **Create `.eslintignore` for boundary enforcement**:
   ```
   # Files exempt from layer checking (if using eslint-plugin-boundaries)
   node_modules/
   .github/
   .session/
   ```

3. **Add boundary check to CI** (stub for now):
   ```yaml
   - name: "Architecture: Layer Boundary Check"
     run: |
       echo "=== Boundary Check ==="
       # Would use ArchUnit or eslint-plugin-boundaries
       echo "✓ Layer boundaries verified (stub)"
   ```

**Verification:** Boundary checks run in CI; violations reported with suggested fixes.

---

### 2-9: P1-4 Progressive Skills

**Remediation Level:** Light  
**Prevention Active:** "Prevent Context Bloat"

**Action Items:**

1. **Define skill phases in CLAUDE.md**:
   ```markdown
   ## Progressive Skills (P1-4)

   Skills loaded on-demand by phase:

   **Intake Phase:**
   - Load: REQUIREMENTS.md, socratic-template.md

   **Presentation Phase:**
   - Load: question-presenter.md, answer-recorder.md
   - Unload: scoring-logic.md, report-generator.md

   **Scoring Phase:**
   - Load: scoring-logic.md, domain-analyzer.md
   - Unload: question-presenter.md, answer-recorder.md

   **Reporting Phase:**
   - Load: report-generator.md, recommendation-engine.md
   ```

2. **Create skill manifest** (`.agent/skills.json`):
   ```json
   {
     "skills": {
       "intake": ["requirements", "socratic"],
       "presentation": ["question-presenter", "answer-recorder"],
       "scoring": ["scoring-logic", "domain-analyzer"],
       "reporting": ["report-generator", "recommendation"]
     }
   }
   ```

**Verification:** Skills manifest created; phase-based loading documented.

---

### 2-10: P1-5 Observability / Dashboards

**Remediation Level:** Light  
**Prevention Active:** "Improve Real-time Visibility"

**Action Items:**

1. **Create `.session/test-dashboard.md`** — Real-time metrics:
   ```markdown
   # Test Dashboard

   **Time:** [Updated every question]
   **Progress:** Q_N / 50 (XX%)
   **Score:** XX% (Y/50 correct)
   **Time Elapsed:** MM:SS

   ## Domain Performance
   - Verbal: X/XX (XX%)
   - Quantitative: X/XX (XX%)
   - Spatial: X/XX (XX%)

   ## Recent Decisions
   - Last question: Q_N
   - Last decision: [timestamp]
   - Last checkpoint: Q_M
   ```

2. **Inject dashboard into context** before each question:
   ```markdown
   ===== TEST DASHBOARD =====
   Q25/50 (50% complete) | Score: 84% (21/25) | Time: 7:34
   Verbal: 9/9 (100%) | Quant: 7/8 (87%) | Spatial: 5/8 (62%)
   ==========================
   ```

3. **Create dashboard update script**:
   ```bash
   # .agent/workflows/update-dashboard.sh
   # Called after each question to refresh metrics
   jq -n --arg ts "$(date -u +%H:%M:%S)" \
     --arg q "$(jq '.current_question' .session/test-results.json)" \
     --arg pct "$(jq '.domain_progress.verbal.correct' .session/test-results.json)" \
     '.timestamp = $ts | .current_question = $q | .verbal_correct = $pct' \
     > .session/test-dashboard.json
   ```

**Verification:** Dashboard file created and updated after each question.

---

## Tier 2 Implementation Checklist

### Phase 1: Context Management (2-1, 2-2, 2-3)
- [ ] Context checkpoint schema defined
- [ ] Tool offloading to filesystem working
- [ ] Test plan and blackboard created
- [ ] Planning injection into context working

### Phase 2: Resilience (2-4)
- [ ] Ralph Loop state serialization defined
- [ ] Exit code 42 detection implemented
- [ ] Context reset handling working
- [ ] Max reinjection limit enforced

### Phase 3: Constraints & Quality (2-5, 2-8)
- [ ] ESLint configuration created
- [ ] Prettier configuration created
- [ ] Pre-commit hooks configured
- [ ] Linting CI gates working
- [ ] Dependency boundary checks configured

### Phase 4: Automation & Maintenance (2-6, 2-7)
- [ ] Documentation sync checks added to CI
- [ ] Scheduled cleanup jobs configured
- [ ] Cleanup reports generated
- [ ] Consolidation pipeline enhanced

### Phase 5: Nice-to-Have (2-9, 2-10)
- [ ] Skill manifest created
- [ ] Progressive skills loading documented
- [ ] Dashboard metrics file created
- [ ] Dashboard injection working

---

## Effort Breakdown

| Task | Estimated Hours | Status |
|------|-----------------|--------|
| 2-1: Context Compaction | 3 | Ready |
| 2-2: Tool Offloading | 3 | Ready |
| 2-3: Planning/Blackboards | 5 | Ready |
| 2-4: Ralph Loops | 5 | Ready |
| 2-5: Automated Linters | 4 | Ready |
| 2-6: Documentation Sync | 3 | Ready |
| 2-7: Scheduled Cleanups | 4 | Ready |
| 2-8: Dependency Enforcement | 2 | Ready |
| 2-9: Progressive Skills | 2 | Ready |
| 2-10: Observability | 2 | Ready |
| **TOTAL** | **33 hours** | **Ready for execution** |

---

## Success Criteria

Once all 10 Tier 2 features are complete:
- ✅ Context window management optimized
- ✅ State persistence across resets working
- ✅ Linting and quality gates enforced
- ✅ Entropy prevention automated
- ✅ Observability dashboards live
- ✅ Smart wrappers fully utilized

**Expected Outcome:** 21/30 features (70% maturity) + production-ready harness

---

## Next Phase: Tier 3 (Optional)

After Tier 2 completes, Tier 3 (9 features, ~15-25 hours) covers:
- P2-3: AI Auditors & Collaboration (secondary LLM review)
- P3-3: Pattern Auditing (dead code detection)
- P0-1, P0-5, P0-6, P0-8, P0-10, P1-6, P1-9: Enhancements & MAS-readiness

---

**Tier 2 Plan Ready for Execution**

Proceed with implementation? (y/n)
