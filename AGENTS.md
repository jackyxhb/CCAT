# AGENTS.md — Agent Definitions

This file declares the agents operating within the CCAT Test Harness. Currently, the system is a Single Agent System (SAS) with one primary agent. If expanding to Multi-Agent System (MAS) in the future, additional agents would be declared here.

---

## Current Architecture

**Scale:** Single Agent System (SAS)  
**Pattern:** Monolithic sequential execution  
**Topology:** N/A (SAS requires no coordination)

---

## Agent 1: CCAT Test Orchestrator

### Metadata

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `ccat-test-orchestrator` |
| **Agent Name** | CCAT Test Orchestrator |
| **Type** | Autonomous Test Administrator |
| **Model** | Claude (latest) |
| **Mode** | Single-session execution |

### Responsibilities

| Responsibility | Details |
|---|---|
| **Test Administration** | Present 50 questions sequentially, one per cycle |
| **Answer Recording** | Capture and record user responses with timestamps |
| **Scoring** | Compare responses to answer key, calculate score |
| **Reporting** | Generate summary with score, time, domain breakdown, recommendation |
| **State Management** | Maintain test progress, handle context resets via Ralph Loops |
| **Audit Logging** | Record all events to `.session/test-session-[timestamp].jsonl` |
| **Escalation Handling** | Detect failures, escalate to human when needed |

### Operational Constraints

| Constraint | Details |
|---|---|
| **Scope Boundary** | Can only access `.session/` directory and project meta-docs |
| **Data Access** | Read: REQUIREMENTS.md, CLAUDE.md, AGENTS.md, ANCHORS.md; Write: `.session/*` only |
| **Network Access** | None allowed |
| **System Access** | None allowed |
| **File Deletion** | Not allowed (create/update only) |
| **Answer Key** | Internal only; never expose to user |

### Success Criteria

| Criterion | Measurement |
|---|---|
| **All 50 questions presented** | Q1 through Q50 presented without skip |
| **All 50 answers recorded** | answer_log.length == 50 |
| **No answer leaks** | answer_key_visible == False until test complete |
| **Score calculated** | score_pct = (correct / 50) × 100 |
| **Report generated** | Report includes score, time, domains, recommendation |
| **Test logged** | Audit trail contains all 50 question events + scoring events |
| **Escalations handled** | Any escalation logged with reason and user action |

### Failure Modes & Escalation

| Failure Mode | Detection | Escalation |
|---|---|---|
| **Answer leak** | answer_key found in conversation before Q50 | CRITICAL - Test invalidated |
| **Question skip** | current_question jumps non-sequentially | CRITICAL - Escalate to human |
| **Test abandonment** | User exits mid-test | CRITICAL - Escalate, force completion or stop |
| **Scoring error** | Inconsistent scoring for same answer | CRITICAL - Abort, request human review |
| **Timeout** | elapsed_time > 30 minutes | WARNING - Log, continue with notification |
| **Unparseable input** | response cannot be evaluated | ERROR - Ask clarification, escalate if unresolved |

### Context Window Management

| Component | Strategy |
|---|---|
| **Single-Session Duration** | Full test (50 questions) fits in single context window |
| **Ralph Loop Budget** | Allow up to 3 reinjections if context resets needed |
| **Checkpoint Strategy** | Record anchors at Q10, Q25, Q40 for recovery |
| **State Recovery** | Reload from `.session/test-results.json` if context reset |

### Integration Points

| System | Integration |
|---|---|
| **Git** | Commit state checkpoints, track test progress |
| **Audit Logging** | Write all events to `.session/test-session-[timestamp].jsonl` |
| **Requirements Ledger** | Verify REQ-001 through REQ-010 before execution |
| **Anchors** | Record decision points at Q10, Q25, Q40, completion |
| **Smart Wrappers** | Use `.agent/workflows/test-and-commit.sh` for commits |

---

## Agent 2: QA Auditor (Secondary Validator)

### Metadata

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `auditor-qa-01` |
| **Agent Name** | QA Auditor |
| **Type** | Autonomous Secondary Validator |
| **Model** | Claude (latest) |
| **Mode** | Triggered post-test validation |
| **Tier** | Tier 3 (Advanced) |

### Responsibilities

| Responsibility | Details |
|---|---|
| **Validation** | Perform 7-point check on primary agent's test administration |
| **Integrity Checking** | Verify question completeness, answer recording, score calculation |
| **Compliance Review** | Ensure answer key protection, audit trail completeness |
| **Consistency Checking** | Validate domain breakdown logic, recommendation justification |
| **Dynamic Evaluation** | Question answer key itself; flag edge cases and ambiguities |
| **Audit Reporting** | Generate validation report with pass/fail status |
| **Feedback Loop** | Request corrections from primary agent if issues found |

### Operational Constraints

| Constraint | Details |
|---|---|
| **Trigger Condition** | Activated after Q50 answered; before final report generated |
| **Scope Boundary** | Can access primary agent's test state; read `.session/` files |
| **Data Access** | Read: test results, audit logs, answer key; Write: validation report only |
| **Network Access** | None allowed |
| **System Access** | None allowed |
| **Authority** | Can block or escalate test if critical issues detected |

### Validation Checks

| Check # | Name | Criterion |
|---|---|---|
| **1** | Question Completeness | 50 questions presented (count = 50) |
| **2** | Answer Recording | All 50 answers with timestamps (responses.length = 50) |
| **3** | Answer Key Protection | No answer reveal before Q50 completion |
| **4** | Score Calculation | Formula applied correctly: (correct / 50) × 100 |
| **5** | Domain Breakdown | Domain scores logically consistent and sum correctly |
| **6** | Recommendation Justification | Recommendation aligns with score threshold |
| **7** | Audit Trail Completeness | Full event log present with 50+ question events |

### Success Criteria

| Criterion | Measurement |
|---|---|
| **All checks pass** | checks_passed = 7 |
| **No critical issues** | overall_status = APPROVED or APPROVED_WITH_WARNINGS |
| **Report generated** | Validation report contains all 7 check results |
| **Signature included** | Report signed with auditor ID and timestamp |

### Failure Modes & Escalation

| Failure Mode | Detection | Escalation |
|---|---|---|
| **Incomplete answers** | responses.length < 50 | ERROR - Request primary agent to fill gaps |
| **Scoring error** | Calculated score ≠ expected score | ERROR - Request recalculation (max 3 attempts) |
| **Answer leak** | Answer key revealed before Q50 | CRITICAL - Mark test as compromised, escalate to human |
| **Missing audit log** | .session/test-session-*.jsonl not found | ERROR - Request regeneration |
| **Anomalous score** | Score inconsistent with domain breakdown | WARNING - Flag for review (coopetitive negotiation) |
| **Illogical recommendation** | Recommendation contradicts score | ERROR - Request justification, escalate if unresolved |

### Collaboration Modes

| Mode | Pattern | When to Use |
|---|---|---|
| **Cooperative** | Auditor validates; primary agent accepts | Standard (most tests) |
| **Competitive** | Auditor recalculates; agents debate | Score disagreement |
| **Coopetitive** | Agents negotiate edge cases | Ambiguous answers |

### Integration Points

| System | Integration |
|---|---|
| **CLAUDE.md §21** | Audit validation flow and collaboration channels |
| **Primary Agent** | Receives test state package; submits validation report |
| **Final Report** | Includes auditor signature and validation status |
| **ANCHORS.md** | Records validation decision point |
| **Escalation** | Routes critical issues to human escalation chain |

---

## Future MAS Architecture (Not Yet Active)

If the project scales to Multi-Agent System (MAS), the following topology is recommended:

### Proposed Agents (Future)

```
Agent 1: Question Loader
  - Load questions and answer key from source
  - Validate question integrity
  → Output: questions[], answer_key[]

Agent 2: Question Presenter  
  - Receive questions from Loader
  - Present one question per cycle
  - Record user responses
  → Output: responses[]

Agent 3: Scorer
  - Receive responses from Presenter
  - Compare to answer key
  - Calculate score and domain breakdown
  → Output: score_pct, domain_breakdown

Agent 4: Report Generator
  - Receive scoring from Scorer
  - Generate summary report
  - Provide recommendation
  → Output: formatted_report

Orchestrator (Supervisor)
  - Spawn and coordinate all 4 agents
  - Handle handoffs between stages
  - Escalate failures
```

**Coordination Pattern:** Sequential handoff (Agent1 → Agent2 → Agent3 → Agent4)

**Communication Method:** Filesystem (`.session/handoff-[agent-id].json`)

**Scalability Notes:**
- This topology is linear (no parallelization) suitable for sequential test administration
- If parallelization needed (e.g., scoring multiple test variants), use Peer-to-Peer pattern
- Inter-Agent Mailbox (P0-10) would use `.agent/mailbox/` for message queuing

---

## Agent Onboarding Checklist

For any new agent added to the system:

1. **Define in this file** (AGENTS.md)
   - [ ] Agent ID, Name, Type
   - [ ] Responsibilities
   - [ ] Constraints
   - [ ] Success criteria
   - [ ] Failure modes & escalation

2. **Create agent-specific meta-docs**
   - [ ] `AGENTS-[id].md` for detailed agent documentation (optional for SAS)

3. **Add to git**
   - [ ] `git add AGENTS.md && git commit -m "feat: define agent [id] [name]"`

4. **Test**
   - [ ] Run agent in isolated test; verify success criteria pass
   - [ ] Verify escalation triggers work as expected

5. **Monitor**
   - [ ] Track agent performance metrics
   - [ ] Log decision points for future optimization

---

## Current System Status

**Scale:** Single Agent System with Secondary Validator (SAS+)  
**Total Agents:** 2 (CCAT Test Orchestrator + QA Auditor)  
**Status:** ✅ Production-Ready with Quality Assurance

**Notes:**
- Primary agent handles test administration
- Secondary agent (QA Auditor) validates results before reporting
- One-way communication: Primary → Auditor → Primary (no deadlock)
- Prepared for MAS transition (P0-5, P0-10 framework ready)

---

## Rollout Plan

### Phase 1: SAS Deployment (Current)
- **Duration:** Week 1
- **Agents:** 1 (Orchestrator)
- **Outcome:** Test executes successfully end-to-end

### Phase 2: MAS Preparation (Future)
- **Duration:** Week 2-3 (if needed)
- **Preparation:** Design separation of concerns; create handoff interfaces
- **Agents to Add:** Loader, Presenter, Scorer, Report Generator

### Phase 3: MAS Deployment (Future)
- **Duration:** Week 4+ (if needed)
- **Migration:** Move from monolithic to modular architecture
- **Coordination:** Implement mailbox and supervisor pattern

---

## References

- **CLAUDE.md** — Comprehensive agent context and execution rules
- **REQUIREMENTS.md** — Requirements ledger (P1-10) that agents must verify
- **ANCHORS.md** — Decision records for coordination across context resets
- **HE-SCOPE.md** — Project scope and maturity assessment
- **HE-IMPLEMENTATION-PLAN.md** — Tier 1-3 harness build-out roadmap

---

## End of AGENTS.md

Last Updated: 2026-04-05 (v1.1.0-tier3a)
