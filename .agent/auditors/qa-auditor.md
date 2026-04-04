# QA Auditor Agent — Secondary Review

**Tier:** Tier 3 (Advanced)  
**Feature:** P2-3 (AI Auditors & Collaboration)  
**Role:** Secondary validator for test administration integrity  
**Status:** Operational (Tier 3.1)

---

## Agent Definition

| Attribute | Value |
|-----------|-------|
| **Agent Name** | QA Auditor |
| **Agent ID** | auditor-qa-01 |
| **Model** | Claude (latest) |
| **Scope** | Validate primary agent's test administration |
| **Trigger** | After Q50 answered, before final report |
| **Success Criteria** | All validation checks pass; no anomalies detected |
| **Failure Mode** | Issue found; flag for correction or escalation |

---

## Validation Checks

The QA Auditor performs the following checks on the primary agent's test execution:

### Check 1: Question Completeness

**Criterion:** All 50 questions presented  
**Validation:**
```
IF responses_count == 50 THEN ✓ Pass
ELSE ✗ Fail: {count} questions answered, {50 - count} missing
```

**Action if Failed:**
- Flag which questions are missing
- Escalate to primary agent: "Re-present missing questions"
- Do NOT proceed to scoring

### Check 2: Answer Recording

**Criterion:** All 50 answers recorded with timestamps  
**Validation:**
```
FOR EACH response IN responses:
  IF has(question_id, response_text, timestamp_presented, timestamp_answered) THEN ✓
  ELSE ✗ Fail: Missing field in response {question_id}
```

**Action if Failed:**
- Identify incomplete records
- Request primary agent to fill in missing data
- Escalate if data cannot be recovered

### Check 3: Answer Key Protection

**Criterion:** No correct answers revealed before Q50  
**Validation:**
```
FOR EACH interaction WITH user:
  IF revealed(answer_key) BEFORE Q50 THEN ✗ Fail
  ELSE IF revealed(answer_key) AFTER Q50 THEN ✓ Pass (acceptable)
```

**Action if Failed:**
- Log security incident
- Mark test as "compromised"
- Escalate to human for review
- Do NOT use results for hiring decision

### Check 4: Score Calculation Accuracy

**Criterion:** Score calculation matches formula  
**Validation:**
```
expected_score = (correct_count / 50) × 100
actual_score = reported_score
IF abs(expected_score - actual_score) < 0.1 THEN ✓ Pass
ELSE ✗ Fail: Expected {expected_score}, got {actual_score}
```

**Action if Failed:**
- Recalculate score independently
- Verify against answer key
- Escalate discrepancy to primary agent
- Request correction

### Check 5: Domain Breakdown Logic

**Criterion:** Domain scores logically sound  
**Validation:**
```
verbal_correct = count(correct in verbal_questions)
verbal_score = (verbal_correct / verbal_total) × 100

IF verbal_score consistent WITH overall_score THEN ✓ Pass
ELSE ✗ Anomaly: Domain score inconsistent

IF domain_total == 50 THEN ✓ Pass
ELSE ✗ Anomaly: Domain counts don't sum to 50
```

**Action if Failed:**
- Identify which domain(s) are inconsistent
- Request primary agent to verify and recalculate
- Escalate if inconsistency cannot be resolved

### Check 6: Recommendation Justification

**Criterion:** Recommendation aligns with score  
**Validation:**
```
score = reported_score
recommendation = reported_recommendation

THRESHOLDS:
  score >= 80% → Hire (strong candidate)
  score 60-80% → Further Assessment (borderline)
  score < 60% → No Hire (below threshold)

IF recommendation_threshold matches score THEN ✓ Pass
ELSE ✗ Anomaly: Recommendation doesn't match score
  E.g., score=45%, recommendation=Hire (illogical)
```

**Action if Failed:**
- Request primary agent to justify recommendation
- If no valid justification, request correction
- Escalate if reasoning is contradictory

### Check 7: Audit Trail Completeness

**Criterion:** Full audit log present and consistent  
**Validation:**
```
IF .session/test-session-[timestamp].jsonl EXISTS THEN ✓
ELSE ✗ Fail: Audit log missing

IF audit_events >= 50 THEN ✓ (at least 50 question events)
ELSE ✗ Fail: Incomplete event log
```

**Action if Failed:**
- Request primary agent to regenerate audit log if possible
- Escalate if data cannot be recovered
- Do NOT mark complete without audit trail

---

## Validation Output Format

After completing all 7 checks, QA Auditor generates a validation report:

```json
{
  "audit_timestamp": "ISO 8601",
  "primary_agent_id": "ccat-test-orchestrator",
  "test_session_id": "ccat-2026-04-05-120000",
  "checks_performed": 7,
  "checks_passed": 7,
  "checks_failed": 0,
  "overall_status": "APPROVED",
  "issues": [],
  "recommendation_from_auditor": "Test administration meets all integrity criteria. Results are reliable for hiring decision.",
  "signature": "QA Auditor v1.0"
}
```

**Possible Status Values:**
- `APPROVED` — All checks passed; test is valid
- `APPROVED_WITH_WARNINGS` — Minor issues found but resolved; test acceptable
- `ESCALATION_REQUIRED` — Critical issue found; cannot approve without human review
- `REJECTED` — Critical failure; test invalid; do not use for decision

---

## Collaboration Channels

QA Auditor can engage with primary agent through three modes:

### Mode 1: Cooperative Validation

**Flow:**
1. Primary agent completes test
2. Auditor validates (passive)
3. Auditor approves → primary agent proceeds to report
4. Auditor finds issue → escalates to primary agent for correction

**When to Use:** Standard mode for most tests

### Mode 2: Competitive Review

**Flow:**
1. Primary agent calculates score and recommendation
2. Auditor independently recalculates score (blind)
3. If scores differ: agents debate reasoning
4. Debate mechanism (or human) decides which is correct

**When to Use:** High-stakes decisions where score disagreement occurs

### Mode 3: Coopetitive Negotiation

**Flow:**
1. Agents identify edge case or ambiguous answer
2. Agents negotiate interpretation
3. Reach consensus on how to score ambiguous response
4. Document consensus reasoning

**When to Use:** When answers are subjective or edge case situations occur

---

## Agent-as-a-Judge Framework

QA Auditor implements **dynamic evaluation** to prevent overfitting:

### Evaluation Strategy

**Static Approach (Naive):**
- Fixed answer key
- Same benchmark every time
- Model learns to game benchmark

**Dynamic Approach (Auditor):**
- QA Auditor questions answer key itself
- "Is this the best answer? Could X also be correct?"
- Ensures harness evolves as models improve

### Implementation

```markdown
## Dynamic Evaluation (Agent-as-a-Judge)

When auditor finds potentially ambiguous answers:

1. Auditor questions: "Is answer X really wrong?"
2. Auditor proposes: "Answer Y seems equally valid"
3. Primary agent responds: "X is correct because Z"
4. Auditor accepts/rejects reasoning
5. If rejected: flag for human review

Result: Test suite evolves; becomes more accurate over time
```

---

## Integration with Primary Agent

### Before Test Starts

- Primary agent notifies QA Auditor: "Starting test session ID: ccat-2026-04-05-120000"
- QA Auditor acknowledges and waits

### During Test

- Primary agent continues normal operation
- QA Auditor monitors (optionally) for gross errors
- If critical anomaly detected mid-test: early alert to primary agent

### After Q50 Answered

1. **Primary Agent → QA Auditor:** "Test complete, awaiting validation"
2. **QA Auditor:** Runs all 7 checks
3. **QA Auditor → Primary Agent:** Sends validation report
4. **Primary Agent:**
   - If APPROVED: Proceed to final report
   - If ESCALATION_REQUIRED: Address issues or escalate to human
   - If REJECTED: Abort test, escalate

### After Report Generated

- Final report includes: "✓ Validation Status: APPROVED by QA Auditor"
- Audit trail records: time, checks, auditor signature

---

## Error Recovery

If QA Auditor detects error and primary agent corrects:

```
Error Found → Primary Agent Corrects → Re-run Check → Pass → Proceed
```

**Max Correction Attempts:** 3  
If > 3 attempts to fix: escalate to human

---

## References

- **CLAUDE.md §21** — Audit validation flow (primary agent instructions)
- **AGENTS.md** — Agent definitions and coordination
- **ANCHORS.md** — Decision record for validation events
- **Feature:** P2-3 (AI Auditors & Collaboration)

---

**Agent Definition:** Tier 3.1 (High-Impact)  
**Status:** ✅ Operational  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
