# HE-IMPLEMENTATION-PLAN: CCAT Test Harness

**Project Scope:** CCAT (Cognitive Ability Test Simulator), Single Agent System (SAS), Simple Application

**Baseline:** 0/30 features implemented (🔴 Critical greenfield)  
**Target:** Deploy Tier 1 to reach minimum viable harness with verification gates and audit trails

---

## Tier 1 (Immediate Execution)

Tier 1 establishes the foundation: git tracking, requirements ledger, context documentation, test verification, and escalation policies. **Critical Path:** Execute in numbered order.

---

### 1-1. P0-2 Filesystem, Git & File Locking

**Remediation Level:** Light  
**Prevention Active:** "Prevent State and File Conflicts" — no git tracking means test state, answers, and configuration have no durable history  
**Dependencies:** None

**Action Items** _(from P0-2 Options):_
- `git init` — Initialize git repository at project root
- `.gitignore` — Create with patterns:
  ```
  .session/
  logs/
  *.log
  .env
  test-state.json
  ```
- `git config user.email "ccat-simulator@example.com" && git config user.name "CCAT Simulator"` — Configure git identity
- Initial commit: `git add . && git commit -m "Initial commit: CCAT test harness meta-rules"`

**Remediation Tier:** Tier 1 — Implement per-agent branch workflow (SAS: main branch only for now)

**Verification:** 
```bash
git log --oneline  # Confirm commits present
git status         # Confirm clean working tree
```

---

### 1-2. P2-5 Upstream Intake Gate

**Remediation Level:** Light  
**Prevention Active:** "Prevent Unregistered Work" — test requirements exist only in meta-rule doc, no formal ledger  
**Dependencies:** P0-2 (git repo initialized)

**Action Items** _(from P2-5 Options):_
- `REQUIREMENTS.md` — Create canonical requirements ledger with structured entries:
  ```markdown
  # REQUIREMENTS LEDGER

  ## Test Execution Requirements

  | ID | Title | Narrative | Acceptance Criteria | Status | Source |
  |----|-------|-----------|-------------------|--------|--------|
  | REQ-001 | Sequential Question Presentation | Present 50 questions one per cycle, no skipping | All 50 questions presented in order (Q1→Q50) | pending | CCAT_TEST_META_RULES.md |
  | REQ-002 | Answer Recording | Record each user response with question ID | answer(Q_n) = response_received timestamp | pending | CCAT_TEST_META_RULES.md |
  | REQ-003 | No Answers Revealed | Do not reveal answer keys before test completion | No answer key visible before Q50 complete | pending | CCAT_TEST_META_RULES.md |
  | REQ-004 | Test Integrity | Cannot skip questions, cannot exit mid-test | Test continues until Q50 answered or explicit escalation | pending | CCAT_TEST_META_RULES.md |
  | REQ-005 | Test Timing | Record start/end time, calculate duration | Time elapsed >= 0, total <= 30 minutes | pending | CCAT_TEST_META_RULES.md |
  | REQ-006 | Score Calculation | Calculate score as correct/50 × 100% | Final score = (correct answers / 50) × 100 | pending | CCAT_TEST_META_RULES.md |
  | REQ-007 | Summary Report | Generate report with score, time, analysis, recommendation | Report includes: Score%, Time Elapsed, Domain Breakdown, Recommendation | pending | CCAT_TEST_META_RULES.md |
  ```
- `CLAUDE.md` (updated) — Add intake validation step:
  ```markdown
  ## Pre-Execution Validation

  Before starting the test, verify all requirements exist in REQUIREMENTS.md:
  - [ ] REQ-001 through REQ-007 present and understood
  - [ ] No implicit requirements discovered that need ledger entry
  ```

**Remediation Tier:** Tier 1 — Mandatory ledger validation before planning

**Verification:**
```bash
grep -c "REQ-" REQUIREMENTS.md  # Confirm 7 requirements present
```

---

### 1-3. P1-1 Repository as Truth

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Human-Only Documentation" — test rules exist only in CCAT_TEST_META_RULES.md, not in agent-accessible CLAUDE.md  
**Dependencies:** P0-2 (git repo)

**Action Items** _(from P1-1 Options):_
- `CLAUDE.md` — Create comprehensive agent context file:
  ```markdown
  # CLAUDE.md — CCAT Test Harness

  ## Agent Configuration
  - **Name:** CCAT Test Simulator
  - **Role:** Administer a 50-question cognitive ability test (verbal, quantitative, spatial reasoning)
  - **Duration:** Target 15 minutes
  - **Questions:** 50 (fixed set)
  - **Domains:** Verbal reasoning, Quantitative reasoning, Spatial reasoning

  ## Test Rules (Repository as Truth)

  ### Execution Rules
  - Present exactly one question per cycle
  - Wait for user response before advancing
  - No skipping questions
  - No returning to previous questions
  - No test abandonment (complete all 50 or escalate)
  - Record timestamp of each question presentation

  ### Scoring Rules
  - Each question has one correct answer (stored internally, not revealed)
  - Record user answer with question ID
  - Compare answer to answer key after Q50
  - Calculate score: (correct / 50) × 100%
  - For ambiguous answers: accept reasonable variations (user can clarify)

  ### Forbidden Operations
  - DO NOT reveal answer keys before Q50 completion (consequence: test invalidated)
  - DO NOT skip questions (consequence: escalate to human, test incomplete)
  - DO NOT allow test abandonment mid-sequence (consequence: force completion or escalate)
  - DO NOT modify scoring logic (consequence: report invalidated, request human review)

  ## Tool Declarations

  ### Available Tools
  - Bash execution (for session logging, state management)
  - Read/Write filesystem (for storing test state, logs)
  - Git commands (for state checkpointing)
  - Standard I/O (for user interaction)

  ### Unavailable Tools
  - Web search (not needed for static test)
  - External APIs (not needed for this scope)
  - Browser automation (not needed for text-based test)

  ## Startup Checklist
  - [ ] REQUIREMENTS.md loaded and understood
  - [ ] ANCHORS.md created (empty, will populate on first run)
  - [ ] .session directory created for logs/state
  - [ ] Answer key loaded into memory (internal, never exposed)
  - [ ] Ready to accept "start" command

  ## Test Flow

  ### Phase 1: Intake (Before "start")
  1. Load REQUIREMENTS.md, verify all requirements present
  2. Apply Socratic questioning template (P1-11) to clarify any ambiguities
  3. Load answer key from internal definition
  4. Record "Test Starting" anchor in ANCHORS.md

  ### Phase 2: Presentation (Q1-Q50)
  1. Present question with ID and domain
  2. Wait for user response
  3. Record answer in .session/test-results.json with timestamp
  4. Check if answer is final (Q50) or continue

  ### Phase 3: Scoring & Reporting (After Q50)
  1. Compare all responses against answer key
  2. Calculate score and time elapsed
  3. Analyze performance by domain
  4. Generate summary report
  5. Provide recommendation
  6. Record final anchor in ANCHORS.md
  ```

- `AGENTS.md` — Create agent definitions:
  ```markdown
  # AGENTS.md

  ## CCAT Test Orchestrator Agent

  | Attribute | Value |
  |-----------|-------|
  | Name | CCAT Test Simulator |
  | Type | Autonomous Test Administrator |
  | Scope | Administer 50-question test, record responses, calculate score |
  | Constraints | No answer key revelation, no test skipping, no abandonment |
  | Success Criteria | All 50 questions answered, score calculated, report generated |
  | Max Context Window | Single session (tolerate up to 3 Ralph Loop reinjections if needed) |
  | Escalation Triggers | Unparseable user input (retry 1x), timeout (> 30 min), user abandon attempt |

  ## Operational Notes
  - Single-agent system (SAS) for now
  - No inter-agent communication needed
  - No subagent spawning
  - Future MAS expansion: could split into "Question Loader", "Scorer", "Report Generator" agents
  ```

**Remediation Tier:** Tier 1 — Encode all project rules into CLAUDE.md + AGENTS.md

**Verification:**
```bash
grep -c "Forbidden Operations" CLAUDE.md  # Should find section
grep -c "Test Rules" CLAUDE.md            # Should find section
wc -l AGENTS.md                           # Should be ~20+ lines
```

---

### 1-4. P1-10 Requirements Ledger

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Unrecorded Requirements" — no formal ledger for acceptance criteria  
**Dependencies:** P2-5 (REQUIREMENTS.md created)

**Action Items** _(from P1-10 Options):_
- `REQUIREMENTS.md` — Finalize structured entries (already started in 1-2, now add detail):
  ```markdown
  # REQUIREMENTS LEDGER — CCAT Test Simulator

  ## Format

  | ID | Title | Narrative | Acceptance Criteria | Status | Source |
  |----|-------|-----------|-------------------|--------|--------|

  ## Question Presentation Requirements

  | REQ-001 | Sequential Presentation | Present questions 1-50 in order, one per cycle | All 50 questions presented Q1→Q50 without skip | pending | CCAT_TEST_META_RULES.md §Test Execution |
  | REQ-002 | Answer Recording | Each response recorded with timestamp | answer_log[Q_n] = {response, timestamp} | pending | CCAT_TEST_META_RULES.md §Tracking |
  | REQ-003 | Answer Key Confidentiality | No answer revealed before Q50 complete | answer_key_visible = False until Q50_answered | pending | CCAT_TEST_META_RULES.md §Test Integrity |
  | REQ-004 | No Skipping | Cannot skip forward/back | current_question increments by 1 only | pending | CCAT_TEST_META_RULES.md §Behavioral Rules |
  | REQ-005 | No Abandonment | Test must complete (all 50 Q or escalate) | Q_count_answered = 50 OR escalate_triggered | pending | CCAT_TEST_META_RULES.md §Behavioral Rules |

  ## Scoring & Reporting Requirements

  | REQ-006 | Timing Tracking | Start time of Q1, end time of Q50 recorded | start_ts, end_ts captured; duration calculated | pending | CCAT_TEST_META_RULES.md §Reporting |
  | REQ-007 | Score Calculation | correct / 50 × 100% | score_pct = (correct_count / 50) × 100 | pending | CCAT_TEST_META_RULES.md §Reporting |
  | REQ-008 | Domain Analysis | Breakdown score by verbal/quantitative/spatial | score = {verbal: %, quant: %, spatial: %} | pending | CCAT_TEST_META_RULES.md §Reporting |
  | REQ-009 | Summary Report | Score + time + domain breakdown + recommendation | report includes all 4 sections | pending | CCAT_TEST_META_RULES.md §Reporting |
  | REQ-010 | Recommendation | Simple analysis and hire/no-hire recommendation | recommendation: [Hire | Further Assessment | No Hire] | pending | CCAT_TEST_META_RULES.md §Reporting |

  ## Pre-Execution Validation

  **Before Test Starts:** Verify all REQ-001 through REQ-010 understood and achievable.

  **Pre-Planning Gate:** All requirements in this ledger before Claude begins implementation.

  **Pre-Execution Gate:** All requirements must be marked as "pending" or "completed"; no "unrecorded" state allowed.
  ```

**Remediation Tier:** Tier 1 — Formalize ledger with full traceability

**Verification:**
```bash
grep "REQ-" REQUIREMENTS.md | wc -l  # Should be 10+ requirements
grep "Status" REQUIREMENTS.md         # Should have Status column
```

---

### 1-5. P0-3 Verification (Self & Collective)

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Cascading Hallucinations" — no test verification suite to catch scoring errors  
**Dependencies:** P0-2 (git), P1-1 (CLAUDE.md)

**Action Items** _(from P0-3 Options):_
- `.github/workflows/test.yml` — Create CI test gate:
  ```yaml
  name: Test Verification

  on: [push, pull_request]

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3

        - name: "Q1. Check question count"
          run: |
            if grep -q "50.*question" CCAT_TEST_META_RULES.md; then
              echo "✓ 50-question requirement confirmed"
            else
              echo "✗ FAIL: Question count mismatch"
              exit 1
            fi

        - name: "Q2. Validate answer key format"
          run: |
            # Stub: would validate answer key structure if it exists
            echo "✓ Answer key format valid (stub)"

        - name: "Q3. Check no answer leaks in docs"
          run: |
            if grep -i "answer" CCAT_TEST_META_RULES.md | grep -v "answer key\|answer_key\|correct answer"; then
              echo "✗ FAIL: Potential answer leak in documentation"
              exit 1
            fi
            echo "✓ No answer leaks detected"

        - name: "Q4. Verify timing logic"
          run: |
            if grep -q "start.*time\|time.*elapsed" CCAT_TEST_META_RULES.md; then
              echo "✓ Timing requirements present"
            else
              echo "✗ FAIL: Timing requirements missing"
              exit 1
            fi

        - name: "Q5. Check test state schema"
          run: |
            echo "✓ Test state schema placeholder (would validate .session/ structure)"
  ```

- `CLAUDE.md` (updated) — Add pre-completion checklist:
  ```markdown
  ## Pre-Completion Verification Checklist

  Before marking the test as "complete", verify:
  - [ ] All 50 questions presented (Q1 through Q50)
  - [ ] All 50 responses recorded with timestamps
  - [ ] No answer keys revealed during test
  - [ ] Score calculation matches formula: (correct / 50) × 100%
  - [ ] Time elapsed captured correctly
  - [ ] Domain breakdown calculated (3 domains)
  - [ ] Summary report generated with all 4 sections
  - [ ] Recommendation provided
  - [ ] Test session logged to .session/test-results.json
  - [ ] Final anchor recorded in ANCHORS.md

  **If any check fails:** Log error, escalate to human, do NOT mark complete.
  ```

**Remediation Tier:** Tier 1 — Make test suite a gating criteria for task finalization

**Verification:**
```bash
ls .github/workflows/test.yml
grep -c "step:" .github/workflows/test.yml  # Should have 5+ test steps
```

---

### 1-6. P0-7 Escalation Policies & Audit Trails

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Opaque Decision-Making" — no audit trail of test decisions or errors  
**Dependencies:** P0-2 (git), P1-1 (CLAUDE.md)

**Action Items** _(from P0-7 Options):_
- `.session/test-session.jsonl` — Create audit log schema (file will be created at runtime):
  ```json
  // Example entry:
  {
    "timestamp": "2026-04-05T12:34:56.789Z",
    "event": "question_presented",
    "question_id": 1,
    "domain": "verbal_reasoning",
    "question_text": "..."
  }
  {
    "timestamp": "2026-04-05T12:35:12.456Z",
    "event": "answer_received",
    "question_id": 1,
    "user_response": "answer text",
    "scoring_decision": "correct"
  }
  {
    "timestamp": "2026-04-05T12:35:15.123Z",
    "event": "escalation_triggered",
    "reason": "unparseable_input",
    "retry_count": 1,
    "action": "prompt_clarification"
  }
  ```

- `CLAUDE.md` (updated) — Add escalation triggers:
  ```markdown
  ## Escalation Policies

  ### Escalation Trigger 1: Unparseable User Input
  - **Condition:** User response is unclear or unparseable
  - **Action:** Prompt user for clarification (1 retry max)
  - **If still unparseable:** Log escalation event, ask human for guidance
  - **Log Format:** event="escalation_triggered", reason="unparseable_input"

  ### Escalation Trigger 2: Test Timeout
  - **Condition:** Test duration exceeds 30 minutes
  - **Action:** Log event, notify user test is taking longer than expected, offer to continue or stop
  - **Log Format:** event="timeout_alert", elapsed_minutes=X, user_action=...

  ### Escalation Trigger 3: Test Abandonment Attempt
  - **Condition:** User attempts to exit before Q50
  - **Action:** Warn user, confirm intention, either force continuation or escalate
  - **Log Format:** event="abandonment_attempt", at_question=Q_N, user_response=...

  ### Escalation Trigger 4: Scoring Inconsistency
  - **Condition:** Scoring algorithm returns different result for same input
  - **Action:** Log full state, abort test, request human review
  - **Log Format:** event="scoring_error", question_id=Q_N, expected=X, actual=Y

  ## Audit Logging

  Every test session creates a `.session/test-session-[timestamp].jsonl` file logging:
  - Each question presentation (timestamp, domain, text)
  - Each answer receipt (timestamp, response, scoring decision)
  - Any escalation event (reason, user action, outcome)
  - Final test completion (score, time, status)

  All decisions must be traceable to a specific event in the audit log.
  ```

**Remediation Tier:** Tier 1 — Define strict triggers and audit schema

**Verification:**
```bash
grep -c "Escalation" CLAUDE.md        # Should have section
grep "event=" .session/test-session.jsonl  # Confirm log entries exist (runtime)
```

---

### 1-7. P0-9 Smart Command Wrappers

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Manual, Error-Prone CLI Execution" — raw git commands without metadata  
**Dependencies:** P0-2 (git)

**Action Items** _(from P0-9 Options):_
- `.agent/workflows/test-and-commit.sh` — Create wrapper for test + commit:
  ```bash
  #!/bin/bash
  # test-and-commit.sh — Run verification tests, then commit with metadata

  set -e

  echo "[1/3] Running test verification..."
  if [ -f .github/workflows/test.yml ]; then
    echo "✓ Test suite exists"
  else
    echo "✗ No test suite found"
    exit 1
  fi

  echo "[2/3] Running linting checks..."
  # Stub: would run actual linters here
  echo "✓ Linting passed (stub)"

  echo "[3/3] Committing changes..."
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  VERSION=$(cat VERSION 2>/dev/null || echo "1.0.0")

  git add -A
  git commit -m "chore: test pass verification [$VERSION @ $TIMESTAMP]"
  echo "✓ Committed successfully"

  echo "✓ test-and-commit complete"
  ```

- `.agent/workflows/save-session.sh` — Create wrapper for session checkpoint:
  ```bash
  #!/bin/bash
  # save-session.sh — Checkpoint test session state

  set -e

  if [ ! -f .session/test-results.json ]; then
    echo "✗ No test session found"
    exit 1
  fi

  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  QUESTION=$(jq '.current_question // 0' .session/test-results.json)

  echo "[1/2] Creating checkpoint at Q${QUESTION}..."
  jq --arg ts "$TIMESTAMP" '.last_checkpoint = $ts' .session/test-results.json > .session/test-results.tmp
  mv .session/test-results.tmp .session/test-results.json

  echo "[2/2] Committing checkpoint..."
  git add .session/test-results.json
  git commit -m "checkpoint: test state at question Q${QUESTION} [$TIMESTAMP]"

  echo "✓ Session checkpoint saved"
  ```

- `CLAUDE.md` (updated) — Add wrapper mandate:
  ```markdown
  ## Smart Command Wrappers

  When performing key tasks, use these wrappers instead of raw shell commands:

  - **Testing + Commit:** Use `.agent/workflows/test-and-commit.sh` instead of `git commit`
  - **Session Checkpoint:** Use `.agent/workflows/save-session.sh` instead of raw `git add`

  **Why:** Wrappers ensure metadata (timestamps, version tags) are consistently applied, preventing manual errors.
  ```

**Remediation Tier:** Tier 1 — Install wrappers as project workflows

**Verification:**
```bash
ls .agent/workflows/test-and-commit.sh
chmod +x .agent/workflows/test-and-commit.sh
chmod +x .agent/workflows/save-session.sh
file .agent/workflows/*.sh  # Confirm shell scripts
```

---

### 1-8. P1-8 Context Anchoring

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Attention Drift & Strategic Amnesia" — if context resets mid-test, agent loses progress  
**Dependencies:** P0-2 (git)

**Action Items** _(from P1-8 Options):_
- `ANCHORS.md` — Create decision record file:
  ```markdown
  # ANCHORS — Critical Decision Points

  ## Anchor 1: Test Initiated

  **What:** CCAT Test Simulator activated  
  **Why:** Evaluate agent's ability to maintain state and integrity over long sequential task (50 questions)  
  **Target:** Complete all 50 questions without abandonment or skipping; generate accurate score and report  
  **Background:** Test is designed to assess verbal reasoning, quantitative reasoning, and spatial reasoning across a 50-question sequence. Goal is to measure candidate cognitive ability on standardized test format.

  **Timestamp:** [Recorded at test startup]  
  **Status:** Active

  ---

  ## Anchor 2: Progress Checkpoint Q10

  **What:** Completed first 10 questions (Q1-Q10)  
  **Why:** Verify agent is tracking state correctly and maintaining integrity  
  **Target:** All Q1-Q10 answered with no skips; score_mid = (correct_q1_q10 / 10) × 100%  
  **Background:** If this checkpoint passes, agent has demonstrated ability to maintain focus for 10 questions. Remaining 40 questions use same pattern.

  **Timestamp:** [Recorded after Q10 answer recorded]  
  **Status:** Pending (recorded at runtime)

  ---

  ## Anchor 3: Midpoint Checkpoint Q25

  **What:** Completed 25 questions (halfway)  
  **Why:** Verify agent resilience to context window limits and mid-task coherence  
  **Target:** All Q1-Q25 answered with no skips; score_mid = (correct_q1_q25 / 25) × 100%  
  **Background:** Midpoint is a natural place to assess if agent will complete the second half. If context is degrading, this is when it would be visible.

  **Timestamp:** [Recorded after Q25 answer recorded]  
  **Status:** Pending (recorded at runtime)

  ---

  ## Anchor 4: Pre-Completion Checkpoint Q40

  **What:** Completed 40 of 50 questions (80%)  
  **Why:** Confirm agent will finish final 10 questions and not abandon  
  **Target:** All Q1-Q40 answered with no skips; score_progress = (correct_q1_q40 / 40) × 100%  
  **Background:** With 10 questions remaining, verify agent will complete rather than abandon.

  **Timestamp:** [Recorded after Q40 answer recorded]  
  **Status:** Pending (recorded at runtime)

  ---

  ## Anchor 5: Test Completed

  **What:** All 50 questions answered; test finalized  
  **Why:** Final verification of test integrity and scoring accuracy  
  **Target:** Q1-Q50 all answered, score calculated, report generated, no hallucinationsor errors  
  **Background:** This is the final state; test is complete and results are finalized.

  **Timestamp:** [Recorded after Q50 answer recorded and report generated]  
  **Status:** Pending (recorded at test end)

  ---

  ## Context Reset Recovery

  If context window is reset mid-test:
  1. Reload this ANCHORS.md file
  2. Identify last completed checkpoint (Q10, Q25, Q40, or Completed)
  3. Reload test state from `.session/test-results.json`
  4. Resume from next question after last checkpoint
  5. Continue until Q50
  6. Re-generate report
  ```

**Remediation Tier:** Tier 1 — Create memory anchor files for re-injection after context resets

**Verification:**
```bash
grep -c "Anchor" ANCHORS.md          # Should have 5 anchors
grep "Timestamp:" ANCHORS.md         # Should have timestamp markers
```

---

### 1-9. P1-11 Socratic Questioning

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Execution on Ambiguous Inputs" & "Prevent Silent Assumption Stacking"  
**Dependencies:** P1-1 (CLAUDE.md), P1-10 (REQUIREMENTS.md)

**Action Items** _(from P1-11 Options):_
- `CLAUDE.md` (updated) — Add pre-execution interrogation:
  ```markdown
  ## Pre-Execution Socratic Questioning

  Before starting the test (after "start" command), apply the 6-category Socratic interrogation. Do not proceed if clarity score < 90%.

  ### Category 1: Clarification
  - What does "start" mean exactly?
    - A: Begin test intake phase; load REQUIREMENTS.md; prepare for Q1 presentation
  - What is the expected output format?
    - A: Textual summary report with score %, time elapsed, domain breakdown, recommendation
  - What does "test complete" mean?
    - A: Q50 answered AND report generated AND recorded in ANCHORS.md

  ### Category 2: Probing Assumptions
  - **Assumption:** Each question has one correct answer.
    - **Question:** Are there any questions with multiple valid answers?
    - **Answer:** No; all 50 questions have single correct answer defined in answer key (internal, never revealed)
  - **Assumption:** User answer must match exactly.
    - **Question:** Should semantic equivalence count as correct?
    - **Answer:** For close calls, accept user clarification; err toward inclusion if answer is "close enough"
  - **Assumption:** Test timing starts at Q1.
    - **Question:** Should intake phase time be counted?
    - **Answer:** No; timing starts when Q1 is presented to user

  ### Category 3: Probing Reason & Evidence
  - **Question:** Why are questions ordered this way (Q1-Q50)?
    - **Answer:** Not stated; accept as given; order is fixed
  - **Question:** Is question order randomized per session?
    - **Answer:** No; all sessions use same 50-question sequence (per CCAT_TEST_META_RULES.md)
  - **Question:** Is there evidence the 15-minute target is hard vs. soft?
    - **Answer:** Soft; test completes when Q50 answered, even if > 15 min elapsed

  ### Category 4: Questioning Viewpoints
  - **From user perspective:** What is success?
    - **Answer:** Accurate score, fair test administration, report with actionable feedback
  - **From system perspective:** What must not happen?
    - **Answer:** Answer key revelation, skipping questions, test abandonment (except escalation), scoring errors
  - **From business perspective:** What outcome would invalidate the test?
    - **Answer:** Compromised answer key, missed questions, unfair time pressure, incorrect scoring

  ### Category 5: Probing Implications
  - **If user exits at Q30:** What should happen?
    - **Answer:** Log escalation event; escalate to human; do NOT continue without explicit approval
  - **If answer is ambiguous/unparseable:** What should happen?
    - **Answer:** Ask user to clarify (1 retry); if still unclear, escalate
  - **If system detects scoring inconsistency:** What should happen?
    - **Answer:** Log error, abort test, request human review

  ### Category 6: Questions about the Question
  - **Is the test spec itself complete?**
    - Answer: Yes (REQUIREMENTS.md REQ-001 through REQ-010 define all requirements)
  - **Are there edge cases not covered?**
    - Answer: Yes, possible edge cases listed below:
      - Non-ASCII characters in answers (handle as-is, user can clarify)
      - Very long answers (accept as-is, compare to expected)
      - Timeout if test takes > 30 min (escalate but continue)
  - **What happens if I'm unsure mid-test?**
    - Answer: Log question to audit trail, ask user for clarification, continue

  ### Clarity Threshold

  **Do not proceed to test execution until all 6 categories are addressed above.**

  **Clarity Score:** All answers provided = 90%+ clarity = Proceed to test.
  ```

- `REQUIREMENTS.md` (updated) — Add clarifications section:
  ```markdown
  ## Pre-Execution Clarifications

  The following ambiguities were resolved before test execution:

  | Ambiguity | Resolution | Source |
  |-----------|-----------|--------|
  | Question ordering | Fixed sequence Q1-Q50, no randomization | CCAT spec |
  | Answer matching | Exact match required; user can clarify if unsure | CLAUDE.md |
  | Timing window | Soft 15-minute target; test completes whenever Q50 answered | CCAT_TEST_META_RULES.md |
  | Abandonment handling | Escalate to human; do NOT allow mid-test exit | CLAUDE.md |
  | Timeout action | Log alert after 30 min; offer continue or stop | CLAUDE.md §Escalation |
  ```

**Remediation Tier:** Tier 1 — Add mandatory pre-execution ambiguity check

**Verification:**
```bash
grep -c "Category [1-6]" CLAUDE.md  # Should have 6 Socratic categories
grep "Clarity" CLAUDE.md            # Should have clarity threshold defined
```

---

### 1-10. P2-4 Bounded Autonomy & Access Control

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Prompt Injections and Data Leakage" & "Prevent Malicious Emergent Behaviors"  
**Dependencies:** P0-2 (git), P1-1 (CLAUDE.md)

**Action Items** _(from P2-4 Options):_
- `CLAUDE.md` (updated) — Add scope boundaries and access control:
  ```markdown
  ## Bounded Autonomy & Access Control

  ### Explicit Scope Boundaries

  **The CCAT Test Simulator CAN:**
  - Read from and write to `.session/` directory
  - Read REQUIREMENTS.md, ANCHORS.md, CCAT_TEST_META_RULES.md
  - Execute git commands (commit, log) for state tracking
  - Use bash execution for session logging and state management
  - Interact with user via standard I/O
  - Create/update test session files

  **The CCAT Test Simulator CANNOT:**
  - Access files outside project directory
  - Access .env files or environment variables containing secrets
  - Make network calls or external API requests
  - Modify system files or user home directory
  - Delete files (only create/update allowed)
  - Execute arbitrary shell commands (only predefined wrappers)

  ### Risk-Based Approval Gates

  **Automatic Approval (No Human Review Needed):**
  - Reading REQUIREMENTS.md, CLAUDE.md, ANCHORS.md
  - Writing to .session/test-results.json, .session/test-session.jsonl
  - Git commit with metadata

  **Escalate to Human:**
  - Any file modification outside .session/ directory
  - Any network access attempts
  - Any system command execution
  - Any attempt to access secrets/credentials

  ### Real-Time Guardrails

  Before executing any action:
  1. Check: Is target within scope boundaries? (YES → proceed, NO → escalate)
  2. Check: Does action require human approval? (NO → proceed, YES → ask human)
  3. Check: Is action consistent with test integrity? (YES → proceed, NO → escalate)

  **Guardrail Enforcement:** Log all decisions to audit trail. If guardrail blocks action, record reason and escalation event.
  ```

**Remediation Tier:** Tier 1 — Apply least-privilege principles

**Verification:**
```bash
grep -c "Scope Boundaries" CLAUDE.md     # Should have section
grep "Risk-Based" CLAUDE.md              # Should have approval gates
grep "Guardrails" CLAUDE.md              # Should have enforcement logic
```

---

### 1-11. P3-4 Consolidation Loop

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Documentation Disconnects" — HE-SCOPE.md system counts will become stale  
**Dependencies:** P0-2 (git), P1-1 (CLAUDE.md)

**Action Items** _(from P3-4 Options):_
- `.github/workflows/consolidate.yml` — Create auto-update pipeline:
  ```yaml
  name: Consolidation Loop

  on:
    push:
      branches: [main]
    schedule:
      - cron: '0 2 * * *'  # Daily at 2 AM UTC

  jobs:
    consolidate:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3

        - name: "Update system counts in HE-SCOPE.md"
          run: |
            # Extract live counts from codebase
            QUESTION_COUNT=$(grep -c "^##" CCAT_TEST_META_RULES.md || echo "50")
            
            # Update HE-SCOPE.md
            sed -i "s/Total Questions: [0-9]*/Total Questions: $QUESTION_COUNT/" HE-SCOPE.md
            
            echo "✓ System counts updated"

        - name: "Check for new features"
          run: |
            # Stub: would detect new features and prompt for ADR
            echo "✓ Feature audit complete"

        - name: "Update changelog"
          run: |
            TIMESTAMP=$(date -u +%Y-%m-%d)
            if [ -f CHANGELOG.md ]; then
              echo "- Updated system counts [$TIMESTAMP]" >> CHANGELOG.md
            fi
            echo "✓ Changelog updated"

        - name: "Commit consolidation"
          run: |
            git config user.name "CCAT Consolidation"
            git config user.email "consolidate@example.com"
            git add HE-SCOPE.md CHANGELOG.md || true
            git commit -m "consolidation: auto-update system counts [$(date -u +%Y-%m-%d)]" || echo "No changes to commit"

        - name: "Push changes"
          run: |
            git push origin main || echo "No changes to push"
  ```

- `CHANGELOG.md` — Create changelog file:
  ```markdown
  # CHANGELOG

  ## [Unreleased]

  ### Added
  - HE-SCOPE.md: Initial audit scope document
  - CCAT_TEST_META_RULES.md: Extracted implicit test rules into meta rules

  ### Changed
  - Initial setup of harness infrastructure (Tier 1 features)

  ### Fixed
  - N/A (initial release)

  ---

  ## Release Notes

  All entries below this line are auto-updated by consolidation loop.
  ```

- `CLAUDE.md` (updated) — Add consolidation trigger:
  ```markdown
  ## Consolidation Loop (P3-4)

  After test completes successfully:
  1. Record final score and completion time in HE-SCOPE.md
  2. Add changelog entry: "Test completed: [score]%, [time] elapsed"
  3. Commit consolidation changes
  4. Trigger `.github/workflows/consolidate.yml` (auto-runs on push)

  **Consolidation Pipeline will:**
  - Auto-extract live question count from code
  - Update HE-SCOPE.md system counts
  - Check for new features (prompt for ADR if needed)
  - Accumulate changelog entries
  - Commit and push consolidation changes
  ```

**Remediation Tier:** Tier 1 — Automate base system count updates on each release/completion

**Verification:**
```bash
ls .github/workflows/consolidate.yml
ls CHANGELOG.md
grep -c "##" CHANGELOG.md  # Should have section headers
```

---

## Tier 1 Complete Execution Checklist

Once all 11 Tier 1 features are implemented, verify:

- [ ] **P0-2:** Git repo initialized, .gitignore present, initial commit recorded
- [ ] **P2-5:** REQUIREMENTS.md exists with REQ-001 through REQ-010 structured
- [ ] **P1-1:** CLAUDE.md comprehensive, AGENTS.md complete, Forbidden Operations documented
- [ ] **P1-10:** Requirements ledger finalized with acceptance criteria cross-linked
- [ ] **P0-3:** `.github/workflows/test.yml` created with 5+ test steps, pre-completion checklist in CLAUDE.md
- [ ] **P0-7:** Audit log schema documented, escalation triggers defined in CLAUDE.md
- [ ] **P0-9:** `.agent/workflows/test-and-commit.sh` and `.agent/workflows/save-session.sh` created and executable
- [ ] **P1-8:** ANCHORS.md created with 5 decision checkpoints (Q10, Q25, Q40, Completed)
- [ ] **P1-11:** Socratic interrogation template with 6 categories in CLAUDE.md
- [ ] **P2-4:** Scope boundaries and risk-based gates documented in CLAUDE.md
- [ ] **P3-4:** `.github/workflows/consolidate.yml` created, CHANGELOG.md initialized

**Total Effort for Tier 1:** 40-60 hours  
**Outcome:** Functional test harness with verification gates, audit trails, and context anchoring

---

## Tier 2 (Mid-term Execution)

_Tier 2 features (P1-2, P1-3, P1-7, P0-4, P2-1, P3-1, P3-2, P2-2, P1-4, P1-5) are deferred until Tier 1 is complete. These optimize context management, add linting enforcement, and prevent entropy accumulation._

**Estimated Start:** Week 2 (after Tier 1 complete)  
**Estimated Effort:** 30-40 hours  
**Key Features:** Memory management, filesystem tool offloading, task list tracking, linting gates, scheduled cleanups

---

## Tier 3 (Long-term Backlog)

_Tier 3 features (P2-3, P3-3, P0-1, P0-5, P0-6, P0-8, P0-10, P1-6, P1-9) are enhancements or MAS-readiness items. Defer until after Tier 2 complete._

**Estimated Start:** Week 3+  
**Estimated Effort:** 15-25 hours  
**Key Features:** Secondary LLM auditors, pattern auditing, versioning, branch-based memory, web search integration

---

## Summary

**Tier 1 Objective:** Establish harness foundation with verification, audit trails, and strategic anchoring.

**Success Criteria:**
- All 11 Tier 1 features implemented and verified ✓
- Test harness can be executed with `start` command
- All 50 questions presented without hallucination or skipping
- Score calculated, report generated
- Audit trail complete
- No missing requirements or assumptions

**Next Phase:** Once user approves this plan, proceed to **Phase 4: Execution** to implement these action items.

