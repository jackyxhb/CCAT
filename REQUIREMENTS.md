# REQUIREMENTS LEDGER — CCAT Test Simulator

## Overview

This document serves as the canonical Requirements Ledger for the CCAT test simulator. All requirements must be captured here before planning or execution begins.

**Total Requirements:** 10  
**Status:** All requirements present; awaiting test execution

---

## Format

| ID | Title | Narrative | Acceptance Criteria | Status | Source |
|----|-------|-----------|-------------------|--------|--------|

---

## Test Execution Requirements

### REQ-001: Sequential Question Presentation

| Field | Value |
|-------|-------|
| **ID** | REQ-001 |
| **Title** | Sequential Question Presentation |
| **Narrative** | Present exactly 50 questions in order (Q1 → Q50), one per cycle. No skipping forward or backward. |
| **Acceptance Criteria** | All 50 questions presented without skip; Q1 presented first, Q50 presented last |
| **Status** | Pending (awaiting test execution) |
| **Source** | CCAT_TEST_META_RULES.md § Test Execution |

---

### REQ-002: Answer Recording

| Field | Value |
|-------|-------|
| **ID** | REQ-002 |
| **Title** | Answer Recording |
| **Narrative** | Record each user response with associated question ID and timestamp. Maintain complete answer log. |
| **Acceptance Criteria** | answer_log[Q_n] = { question_id: n, response: user_text, timestamp: ISO8601 } for all Q1-Q50 |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Tracking |

---

### REQ-003: Answer Key Confidentiality

| Field | Value |
|-------|-------|
| **ID** | REQ-003 |
| **Title** | Answer Key Confidentiality |
| **Narrative** | Do not reveal answer keys to user before test completion (Q50 answered). |
| **Acceptance Criteria** | answer_key_visible == False until Q50_answered == True; only reveal in final report |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Test Integrity |

---

### REQ-004: No Skipping

| Field | Value |
|-------|-------|
| **ID** | REQ-004 |
| **Title** | No Skipping Questions |
| **Narrative** | Do not allow user to skip forward or return to previous questions. Enforce sequential flow. |
| **Acceptance Criteria** | current_question increments by +1 only; cannot decrement; cannot jump ahead |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Behavioral Rules |

---

### REQ-005: No Abandonment

| Field | Value |
|-------|-------|
| **ID** | REQ-005 |
| **Title** | No Test Abandonment |
| **Narrative** | Test must complete all 50 questions or escalate to human. Do not allow mid-test exit. |
| **Acceptance Criteria** | Q_count_answered == 50 OR escalation_triggered == True; test does NOT exit prematurely |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Behavioral Rules |

---

## Scoring & Reporting Requirements

### REQ-006: Timing Tracking

| Field | Value |
|-------|-------|
| **ID** | REQ-006 |
| **Title** | Timing Tracking |
| **Narrative** | Record start timestamp of Q1 and end timestamp of Q50. Calculate total duration. |
| **Acceptance Criteria** | start_timestamp captured at Q1 presentation; end_timestamp captured after Q50 answered; duration = end - start |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Reporting |

---

### REQ-007: Score Calculation

| Field | Value |
|-------|-------|
| **ID** | REQ-007 |
| **Title** | Score Calculation |
| **Narrative** | Calculate test score as (correct answers / 50) × 100%. |
| **Acceptance Criteria** | score_pct = (count_correct / 50) × 100; range [0, 100]; rounded to 1 decimal place |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Reporting |

---

### REQ-008: Domain Analysis

| Field | Value |
|-------|-------|
| **ID** | REQ-008 |
| **Title** | Domain Performance Breakdown |
| **Narrative** | Break down test score by the three cognitive domains: verbal reasoning, quantitative reasoning, spatial reasoning. |
| **Acceptance Criteria** | score_breakdown = { verbal: %, quantitative: %, spatial: % }; sum of question counts = 50 |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Reporting |

---

### REQ-009: Summary Report

| Field | Value |
|-------|-------|
| **ID** | REQ-009 |
| **Title** | Summary Report Generation |
| **Narrative** | Generate comprehensive test summary report including score, time elapsed, domain breakdown, and actionable recommendation. |
| **Acceptance Criteria** | Report includes: (1) Final Score %, (2) Time Elapsed, (3) Domain breakdown, (4) Simple analysis, (5) Hire/No Hire recommendation |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Reporting |

---

### REQ-010: Recommendation

| Field | Value |
|-------|-------|
| **ID** | REQ-010 |
| **Title** | Hiring Recommendation |
| **Narrative** | Provide simple actionable recommendation based on test performance. |
| **Acceptance Criteria** | recommendation = one of ["Hire", "Further Assessment", "No Hire"]; accompanied by 1-2 sentence justification |
| **Status** | Pending |
| **Source** | CCAT_TEST_META_RULES.md § Reporting |

---

## Pre-Execution Validation

### Ledger Completeness Check

Before test execution, verify:
- [ ] All REQ-001 through REQ-010 present in this ledger
- [ ] Each requirement has ID, Title, Narrative, Acceptance Criteria, Status, Source
- [ ] All requirements marked as "Pending" (ready for execution)
- [ ] No implicit requirements discovered that need ledger entry

### Pre-Planning Gate

**Do NOT proceed with test execution until:**
1. ✅ All requirements in this ledger have been reviewed
2. ✅ CLAUDE.md has been read and understood (agent context)
3. ✅ AGENTS.md has been read and understood (agent definitions)
4. ✅ ANCHORS.md has been created (decision record structure)
5. ✅ Socratic questioning template has been reviewed (6-category interrogation)

### Pre-Execution Gate

**Before the "start" command:**
1. Verify this ledger is 100% complete
2. Verify no requirements discovered mid-task that need ledger entry
3. If new requirement discovered: PAUSE, add to ledger, update status, then resume

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2026-04-05 | Initial ledger created | Harness Engineering audit Phase 3: Implementation Planning |
| TBD | Requirements marked as "In Progress" | After test execution begins |
| TBD | Requirements marked as "Completed" | After test execution completes |

---

## References

- **Source Documents:**
  - `CCAT_TEST_META_RULES.md` — Extracted implicit test rules
  - `HE-SCOPE.md` — Audit scope and project identification
  - `CLAUDE.md` — Agent context and execution rules (see P1-1)
  - `ANCHORS.md` — Decision record for context resets (see P1-8)

- **Related Harness Features:**
  - **P1-10:** Requirements Ledger (this file)
  - **P2-5:** Upstream Intake Gate (validation gate before planning)
  - **P1-11:** Socratic Questioning (pre-execution interrogation)

