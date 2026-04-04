# ANCHORS.md — Critical Decision Points & Strategic Anchors

This file records critical decision points that establish context and prevent "Attention Drift & Strategic Amnesia" (P1-8). If the agent's context window resets mid-test, these anchors serve as recovery points to re-establish the original objective and strategy.

---

## Overview

**Purpose:** Maintain long-term coherence across context resets  
**Format:** Structured decision records (What, Why, Target, Background)  
**Recovery Protocol:** If context resets, reload this file first, then resume from last checkpoint

---

## Anchor 0: Test Specification (Baseline)

**What:** CCAT Test Simulator — Baseline Test Specification  
**Why:** Establish canonical test definition before execution begins  
**Target:** All test logic conforms to CCAT_TEST_META_RULES.md specification  
**Background:** The CCAT is a 50-question cognitive ability test covering verbal, quantitative, and spatial reasoning. Standard duration is 15 minutes (soft limit). Test evaluates candidate cognitive abilities using a standardized format.

**Timestamp:** 2026-04-05T00:00:00Z (Specification baseline)  
**Status:** Active (baseline; never changes)

---

## Anchor 1: Test Started

**What:** CCAT Test Simulator activated; intake phase begins  
**Why:** Verify agent can maintain state and integrity over long sequential task (50 questions)  
**Target:** Complete all 50 questions without abandonment or skipping; generate accurate score and report  
**Background:** Test is designed to assess verbal reasoning, quantitative reasoning, and spatial reasoning across a 50-question sequence. Agent must demonstrate:
- Sequential coherence (no skipping, no out-of-order presentation)
- State persistence (remember which questions answered, running score)
- Integrity (no answer key reveals, no modifications)
- Accuracy (correct scoring, accurate report)

**Timestamp:** [Recorded at "start" command execution]  
**Status:** Pending (recorded at test initiation)

**Recovery Instructions:**
If context resets BEFORE Q1 is presented:
- Load REQUIREMENTS.md and verify all 10 requirements present
- Reload CLAUDE.md and review all Socratic categories
- Retry: Ask user to re-issue "start" command

---

## Anchor 2: Progress Checkpoint Q10

**What:** Completed first 10 questions (Q1-Q10)  
**Why:** Verify agent is tracking state correctly and maintaining test integrity  
**Target:** All Q1-Q10 answered without skips; score_progress = (correct_q1_q10 / 10) × 100%  
**Background:** If this checkpoint passes, agent has demonstrated ability to maintain focus for 10 questions. Remaining 40 questions use identical pattern. Checkpoint serves as:
- **Confidence builder:** Shows system can stay on track for extended sequence
- **State validation:** Confirms answer logging is working
- **Mid-point recovery:** If context resets, can resume from Q11

**Timestamp:** [Recorded after Q10 answer recorded]  
**Status:** Pending (recorded at runtime)

**Recovery Instructions:**
If context resets AFTER Q10 completed:
1. Load ANCHORS.md (this file)
2. Identify "Anchor 2: Progress Checkpoint Q10" → last checkpoint reached
3. Load `.session/test-results.json`
4. Extract: Q1-Q10 responses, current score, elapsed time
5. Resume: Present Q11 next; continue to Q50
6. Log: `{ event: "context_reset_recovery", resumed_from: Q11, checkpoint: Q10 }`

---

## Anchor 3: Midpoint Checkpoint Q25

**What:** Completed 25 questions (halfway through test)  
**Why:** Verify agent resilience to context window limits and mid-task coherence  
**Target:** All Q1-Q25 answered without skips; score_mid = (correct_q1_q25 / 25) × 100%  
**Background:** Midpoint is a natural inflection point to assess:
- **Context degradation:** If context is filling up, symptoms appear here
- **Fatigue resistance:** Show agent hasn't lost focus or started hallucinating
- **Recency bias:** Verify early questions (Q1-Q5) are still logged correctly
- **Pacing:** Check if time elapsed is proportional (expected: 7.5 min for 25 questions)

**Timestamp:** [Recorded after Q25 answer recorded]  
**Status:** Pending (recorded at runtime)

**Recovery Instructions:**
If context resets AFTER Q25 completed:
1. Load ANCHORS.md
2. Identify "Anchor 3: Midpoint Checkpoint Q25" → last checkpoint reached
3. Load `.session/test-results.json`
4. Extract: Q1-Q25 responses, current score, elapsed time, domain progress
5. Resume: Present Q26 next; continue to Q50
6. Log: `{ event: "context_reset_recovery", resumed_from: Q26, checkpoint: Q25, domain_scores: {...} }`
7. Inject into context: "Midpoint checkpoint reached. You are 50% complete. Remaining 25 questions follow same pattern."

---

## Anchor 4: Pre-Completion Checkpoint Q40

**What:** Completed 40 of 50 questions (80% progress)  
**Why:** Confirm agent will finish final 10 questions and not abandon  
**Target:** All Q1-Q40 answered without skips; score_progress = (correct_q1_q40 / 40) × 100%  
**Background:** With only 10 questions remaining, checkpoint verifies:
- **Persistence:** Agent shows commitment to completion (not abandoning at 80%)
- **Stability:** No degradation in later questions (compare Q31-Q40 performance to Q1-Q10)
- **Final push:** Psychological checkpoint before final stretch

**Timestamp:** [Recorded after Q40 answer recorded]  
**Status:** Pending (recorded at runtime)

**Recovery Instructions:**
If context resets AFTER Q40 completed:
1. Load ANCHORS.md
2. Identify "Anchor 4: Pre-Completion Checkpoint Q40" → last checkpoint reached
3. Load `.session/test-results.json`
4. Extract: Q1-Q40 responses, final domain scores, elapsed time
5. Resume: Present Q41 next; final 10 questions (Q41-Q50)
6. Log: `{ event: "context_reset_recovery", resumed_from: Q41, checkpoint: Q40, progress: 80% }`
7. Inject into context: "Final 10 questions remaining. You are 80% complete. Finish strong!"

---

## Anchor 5: Test Completed

**What:** All 50 questions answered; test finalized; report generated  
**Why:** Final verification of test integrity and scoring accuracy  
**Target:** Q1-Q50 all answered, score calculated, report generated, no hallucinations or errors  
**Background:** This is the terminal state; test is complete and results are finalized. Anchor verification ensures:
- **Completeness:** All 50 questions answered (Q_count_answered == 50)
- **Integrity:** No answer key leaked, no score modifications
- **Accuracy:** Score calculation verified
- **Reporting:** Report generated with all sections (score, time, domains, recommendation)

**Timestamp:** [Recorded after Q50 answer recorded and report generated]  
**Status:** Pending (recorded at test end)

**Recorded Data (Example):**
```json
{
  "timestamp": "2026-04-05T12:50:00.000Z",
  "event": "test_completed",
  "total_questions": 50,
  "total_correct": 42,
  "score_pct": 84.0,
  "time_elapsed": "14:23",
  "domain_breakdown": {
    "verbal": 90.0,
    "quantitative": 80.0,
    "spatial": 78.0
  },
  "recommendation": "Hire",
  "status": "completed_successfully"
}
```

**Recovery Instructions:**
If context resets AFTER test completed:
1. Load ANCHORS.md
2. Identify "Anchor 5: Test Completed" → test is finished
3. Load `.session/test-results.json`
4. Extract: Final score, time, domain breakdown, recommendation
5. **DO NOT resume test** (all 50 questions already answered)
6. Retrieve and display final report
7. Log: `{ event: "context_reset_post_completion", test_status: "completed", score: 84.0 }`

---

## Context Reset Recovery Protocol

### If Context Resets Mid-Test

**Step 1: Load Anchors** (immediately)
```
Read ANCHORS.md in full
Identify last completed checkpoint (Q10, Q25, Q40, or Completed)
```

**Step 2: Recover State** (within 1 minute)
```
Load .session/test-results.json
Extract: responses[], current_score, elapsed_time, domain_progress
Verify: Q_count_answered matches checkpoint expectation
```

**Step 3: Resume Execution** (without delay)
```
If last checkpoint == Q10:
  Present Q11 next; continue to Q50
  Inject: "Checkpoint Q10 reached. Resuming from Q11."

If last checkpoint == Q25:
  Present Q26 next; continue to Q50
  Inject: "Midpoint checkpoint reached (50% complete). Resuming from Q26."

If last checkpoint == Q40:
  Present Q41 next; continue to Q50
  Inject: "Final 10 questions remaining. Finish strong!"

If last checkpoint == Completed:
  Retrieve final report from .session/test-results.json
  Display to user; do NOT re-test
```

**Step 4: Log Recovery** (always)
```
{
  "event": "context_reset_recovery",
  "recovered_from_checkpoint": "Q_N",
  "resumed_from_question": "Q_N+1",
  "state_integrity": "verified",
  "timestamp": "ISO8601"
}
```

---

## Temporal Checkpoints

### Expected Timeline (15-minute soft limit)

| Checkpoint | Cumulative Time | Cumulative %  | Expected | Actual |
|------------|-----------------|---------------|----------|--------|
| Q10 | 3:00 | 20% | — | — |
| Q25 | 7:30 | 50% | — | — |
| Q40 | 12:00 | 80% | — | — |
| Q50 (Complete) | 15:00 | 100% | — | — |

**Note:** Times are soft targets. Test completes whenever Q50 answered, even if beyond 15 minutes. Escalate if > 30 minutes.

---

## Domain-Specific Anchors (Future)

If test expansion adds domain-specific parallelization:

**Anchor: Verbal Reasoning Checkpoint (Questions 1-17)**  
**Anchor: Quantitative Reasoning Checkpoint (Questions 18-34)**  
**Anchor: Spatial Reasoning Checkpoint (Questions 35-50)**

---

## Escalation Anchor

**What:** Escalation triggered during test  
**Condition:** Test unable to continue (abandonment attempt, scoring error, timeout > 30 min)  
**Action:** Log full state to escalation anchor, request human intervention  
**Recovery:** Human review determines next steps (restart, resume, or abort)

---

## References

- **CLAUDE.md** — Comprehensive agent context; see Section 14 for context reset protocol
- **REQUIREMENTS.md** — Requirements ledger; verify REQ-001 through REQ-010 still present after reset
- **AGENTS.md** — Agent operational constraints; review scope boundaries after reset
- **HE-IMPLEMENTATION-PLAN.md** — Tier 1 implementation (P1-8 Context Anchoring)

---

## End of ANCHORS.md

**Last Updated:** 2026-04-05 (v1.0.0)  
**Anchors Defined:** 5 (Baseline + Q10 + Q25 + Q40 + Completed)  
**Status:** Ready for test execution

These anchors serve as the agent's "memory" across context resets. They are the most critical recovery mechanism for long-horizon test execution.
