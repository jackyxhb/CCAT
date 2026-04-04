# HE-PRIORITIES: CCAT Harness Gap Prioritization

**Assessment Date:** 2026-04-05  
**Audit Scope:** Full 30-feature harness assessment (Team mode, 4 parallel auditors)  
**Maturity Baseline:** 0/30 features implemented (🔴 Critical greenfield)

---

## Executive Summary

The CCAT test simulator is a pre-initialization project with **zero harness infrastructure**. All 30 core features are absent. The audit identifies:

- **9 Critical gaps** requiring immediate remediation
- **15 Important gaps** requiring near-term implementation  
- **6 Enhancement gaps** for longer-term maturity

**Recommended approach:** Implement in **3 tiers** (Immediate → Week 1 → Week 2+), prioritizing prevention of cascading failures and context-window exhaustion.

---

## Tier 1: IMMEDIATE (This Week) — 11 Features

These features prevent cascading failures or enable subsequent features. **Start within 24 hours.**

### Critical Priority (Start First)

| ID | Feature | Pillar | Prevention Failure | Remediation | Status |
|---|---------|--------|-------------------|-------------|--------|
| **P0-2** | Filesystem, Git & File Locking | Foundation | State/file conflicts | Light | Init git repo |
| **P0-3** | Verification (Self & Collective) | Foundation | Cascading hallucinations | Medium | Create test suite |
| **P2-4** | Bounded Autonomy & Access Control | Constraints | Prompt injection, data leakage | Medium | Document scope |
| **P2-5** | Upstream Intake Gate | Constraints | Unregistered work proceeds | Light | Create REQUIREMENTS.md |
| **P1-1** | Repository as Truth | Context | Human-only documentation | Medium | Create CLAUDE.md + AGENTS.md |
| **P1-10** | Requirements Ledger | Context | Unrecorded requirements | Medium | Formalize ledger |

### Important Priority (Parallel with Critical)

| ID | Feature | Pillar | Prevention Failure | Remediation | Status |
|---|---------|--------|-------------------|-------------|--------|
| **P0-7** | Escalation Policies & Audit Trails | Foundation | Opaque decisions, no accountability | Medium | Add logging hooks |
| **P0-9** | Smart Command Wrappers | Foundation | Manual CLI errors | Medium | Create `.agent/workflows/` |
| **P1-8** | Context Anchoring | Context | Attention drift, amnesia | Medium | Create ANCHORS.md |
| **P1-11** | Socratic Questioning | Context | Silent assumption stacking | Medium | Pre-execution interrogation |
| **P3-4** | Consolidation Loop | Entropy | Doc divergence, stale metadata | Medium | Auto-update pipeline |

**Tier 1 Total:** 11 features (6 Critical + 5 Important)  
**Estimated Effort:** 40-60 hours  
**Execution Order:** 
1. P0-2 + P2-5 (Git init + REQUIREMENTS.md) — **Foundation** — 2 hours
2. P1-1 + P1-10 (CLAUDE.md + ledger) — **Context foundation** — 4 hours
3. P0-3 (Test suite) — **Verification** — 8 hours
4. P0-7 + P0-9 (Logging + wrappers) — **Audit trail** — 6 hours
5. P1-8 + P1-11 (ANCHORS.md + Socratic) — **Context anchoring** — 6 hours
6. P2-4 (Bounded autonomy doc) — **Safety gates** — 2 hours
7. P3-4 (Consolidation) — **Automation foundation** — 6 hours

---

## Tier 2: WEEK 1 — 10 Features

These features optimize context window usage and prevent entropy. **Deploy after Tier 1 foundation.**

| ID | Feature | Pillar | Prevention Failure | Remediation | Priority |
|---|---------|--------|-------------------|-------------|----------|
| **P1-2** | Context Compaction & Memory Management | Context | Context rot | Light | High |
| **P1-3** | Tool Offloading | Context | Context rot | Light | High |
| **P1-7** | Planning, Task Lists & Blackboards | Context | Attention drift | Medium | High |
| **P0-4** | Ralph Loops | Foundation | Premature exits | Medium | Medium |
| **P2-1** | Automated Linters | Constraints | Code quality drift | Medium | Medium |
| **P3-2** | Documentation Sync | Entropy | Doc staleness | Medium | Medium |
| **P3-1** | Scheduled Cleanups | Entropy | Dead code accumulation | Medium | Medium |
| **P2-2** | Dependency Enforcement | Constraints | Architectural violations | Medium | Low |
| **P1-4** | Progressive Skills | Context | Context bloat | Light | Low |
| **P1-5** | Observability / Dashboards | Context | Blind spot | Light | Low |

**Tier 2 Total:** 10 features  
**Estimated Effort:** 30-40 hours  
**Execution Order:** Context management first (P1-2, P1-3, P1-7), then constraints (P2-1, P2-2), then entropy (P3-1, P3-2), then enhancements (P0-4, P1-4, P1-5).

---

## Tier 3: WEEK 2+ — 9 Features

These features optimize for multi-agent systems (MAS) readiness or are nice-to-have enhancements. **Deploy after Tier 1 & 2.**

| ID | Feature | Pillar | Prevention Failure | Remediation | Priority |
|---|---------|--------|-------------------|-------------|----------|
| **P2-3** | AI Auditors & Collaboration | Constraints | Single-point-of-failure validation | Heavy | Medium |
| **P3-3** | Pattern Auditing | Entropy | Codebase entropy | Medium | Medium |
| **P0-1** | Bash Sandboxes | Foundation | (Provided by Claude Code) | Light | Low |
| **P0-5** | Orchestration Logic | Foundation | Coordination overhead (SAS only) | Light | Low |
| **P0-6** | Rippable Middleware | Foundation | Over-engineering | Light | Low |
| **P0-8** | Harness Versioning | Foundation | Reproducibility gap | Light | Low |
| **P0-10** | Inter-Agent Communication | Foundation | (SAS doesn't need) | Light | Low |
| **P1-6** | Web Search & MCP | Context | Knowledge cutoff (test-dependent) | Light | Low |
| **P1-9** | Branch-Based Memory | Context | (SAS monolithic) | Light | Low |

**Tier 3 Total:** 9 features  
**Estimated Effort:** 15-25 hours  
**Note:** Most are enhancements or only required for MAS expansion.

---

## Cascade & Dependency Map

**Critical Path** (must complete in order):

```
P0-2 (Git) → P2-5 (Ledger) → P1-1 (CLAUDE.md) → P1-10 (Requirements) 
  ↓
P0-3 (Verification) [enables all downstream testing]
  ↓
P1-8 + P1-11 (Context anchoring) [enables long-running sequences]
  ↓
P1-2 + P1-3 (Memory mgmt) [prevents context overflow]
  ↓
P3-4 (Consolidation) [automates metadata maintenance]
  ↓
Tier 2 & 3 features (optimization & nice-to-have)
```

**Blocking Relationships:**
- P0-3 (Verification) blocks safe execution of any test logic
- P1-1 + P1-10 (Repository truth + Ledger) blocks all downstream P1/P2 features
- P2-5 (Intake gate) blocks P2-1, P2-2, P2-4 implementation
- P1-8 + P1-11 (Context anchoring) blocks P1-2, P1-3 (memory mgmt is only useful if context is anchored)

---

## Severity Scorecard

### By Pillar

| Pillar | Critical | Important | Enhancement | Total | % Critical |
|--------|----------|-----------|-------------|-------|-----------|
| **P0: Foundation** | 4 | 4 | 2 | 10 | 40% |
| **P1: Context** | 2 | 5 | 4 | 11 | 18% |
| **P2: Constraints** | 3 | 2 | 0 | 5 | 60% |
| **P3: Entropy** | 0 | 4 | 0 | 4 | 0% |
| **TOTAL** | **9** | **15** | **6** | **30** | **30%** |

### By Prevention Failure Type

| Failure Category | Count | Examples |
|------------------|-------|----------|
| **Cascading Hallucinations** | 3 | P0-3, P2-1, P3-3 |
| **Context Rot / Window Exhaustion** | 4 | P1-2, P1-3, P1-4, P1-5 |
| **Attention Drift / Amnesia** | 3 | P1-7, P1-8, P1-9 |
| **Unrecorded / Unvalidated Requirements** | 3 | P1-1, P1-10, P1-11 |
| **Constraint Bypass** | 4 | P2-1, P2-2, P2-4, P2-5 |
| **Entropy Accumulation** | 4 | P3-1, P3-2, P3-3, P3-4 |
| **Single Point of Failure** | 1 | P2-3 |

---

## Implementation Timeline

### Week 1 (This Week)
**Target:** Deploy Tier 1 + quick Tier 2 wins  
**Outcome:** Functional test harness with basic verification and audit trails

- **Day 1 (Today):** P0-2, P2-5, P1-1, P1-10 (4 hours)
- **Day 2:** P0-3 test suite (8 hours)
- **Day 3:** P0-7, P0-9, P1-8, P1-11 (8 hours)
- **Day 4:** P2-4 scope documentation (2 hours)
- **Day 5:** P3-4 consolidation pipeline (6 hours)
- **Buffer:** 4 hours for review & rework

### Week 2 (Next Week)
**Target:** Deploy Tier 2 + Tier 3 quick wins  
**Outcome:** Optimized context management + MAS-ready architecture

- Context management (P1-2, P1-3, P1-7): 6 hours
- Constraints hardening (P2-1, P2-2): 6 hours
- Entropy automation (P3-1, P3-2, P3-3): 6 hours
- Tier 3 quick wins (P0-1, P0-6, P0-8): 4 hours
- Buffer: 4 hours

### Week 3+ (Optional)
**Target:** MAS-readiness + advanced features  
**Outcome:** Enterprise-grade harness

- P2-3 (AI auditors): 8-12 hours
- P1-9, P1-6, P0-5, P0-10: 6-8 hours

---

## Success Metrics & Milestones

### Tier 1 Success Criteria
- ✅ Git repo initialized; all meta-docs in source control
- ✅ REQUIREMENTS.md populated with all test requirements
- ✅ CLAUDE.md + AGENTS.md document test spec and agent contract
- ✅ Test verification suite runs (P0-3)
- ✅ Audit logs capture all test events (P0-7)
- ✅ ANCHORS.md records critical decision points (P1-8)
- ✅ Socratic questioning template applied before test execution (P1-11)
- ✅ Consolidation pipeline auto-updates system counts (P3-4)

### Tier 2 Success Criteria
- ✅ Test session state saved to filesystem (P1-2, P1-3)
- ✅ Planning file tracks all 50 questions with status (P1-7)
- ✅ ESLint + Prettier configured + CI gates enforced (P2-1)
- ✅ Scheduled cleanup jobs run weekly (P3-1)
- ✅ Documentation consistency validated in CI (P3-2)

### Tier 3 Success Criteria
- ✅ Static analysis tools detect dead code + circular deps (P3-3)
- ✅ Secondary LLM review pipeline deployed (P2-3)
- ✅ MAS-ready worktree + branch strategy documented (P1-9)

---

## Rollback & Risk Mitigation

**Risk:** Tier 1 features are interdependent; implementing out-of-order may cause rework.  
**Mitigation:** Follow critical path strictly (P0-2 → P2-5 → P1-1/P1-10 → P0-3 → rest).

**Risk:** Test execution cannot begin until P0-3 (verification) is complete.  
**Mitigation:** Acceptance: no test runs happen until Week 1 Day 2-3. Use this time to design test content.

**Risk:** Tier 2 context management features (P1-2, P1-3) add complexity.  
**Mitigation:** Implement incrementally: serialize results to disk (P1-3), then add context summarization (P1-2).

---

## Next Phase: Recommendation & Implementation Planning

Once user reviews this prioritization, proceed to **Phase 3: Recommendation & Implementation Plan**.

This will translate each Tier 1 feature into concrete action items, tools, and file modifications needed to bring the harness from 0/30 to passing each feature's 3-step chain assessment.

