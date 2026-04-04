# HE-TIER3-PLAN: Advanced Features & MAS Readiness

**Tier:** Tier 3 (Long-term / Optional)  
**Target:** Week 3+ (after Tier 2 stable)  
**Estimated Effort:** 15-25 hours  
**Status:** Planning phase

---

## Tier 3 Overview

Tier 3 implements advanced features that are **optional** for single-agent test execution but **essential** for:
- Multi-agent systems (MAS) expansion
- Advanced observability and debugging
- A/B testing and experimentation
- Enterprise-scale deployments
- Research and optimization

### Features (9 Total)

| # | Feature | Pillar | Use Case | Priority |
|---|---------|--------|----------|----------|
| **3-1** | P2-3 AI Auditors & Collaboration | Constraints | Secondary LLM review | High |
| **3-2** | P3-3 Pattern Auditing | Entropy | Dead code detection | High |
| **3-3** | P0-1 Bash Sandboxes | Foundation | Explicit sandbox docs | Low |
| **3-4** | P0-5 Orchestration Logic | Foundation | Multi-agent coordination | Medium |
| **3-5** | P0-6 Rippable Middleware | Foundation | Feature flags + deprecation | Medium |
| **3-6** | P0-8 Harness Versioning | Foundation | A/B testing + metrics | Medium |
| **3-7** | P0-10 Inter-Agent Communication | Foundation | Mailbox system for MAS | Medium |
| **3-8** | P1-6 Web Search / MCP | Context | Real-time knowledge | Low |
| **3-9** | P1-9 Branch-Based Memory | Context | Parallel task execution | Medium |

---

## Execution Strategy

### Tier 3a: High-Impact (Recommended First)
- **3-1:** AI Auditors (secondary review agent)
- **3-2:** Pattern Auditing (automated dead code detection)
- **Effort:** 8 hours
- **Benefit:** High quality assurance; enterprise-grade confidence

### Tier 3b: MAS Foundation (Recommended Second)
- **3-4:** Orchestration Logic (multi-agent coordination)
- **3-7:** Inter-Agent Communication (mailbox system)
- **3-9:** Branch-Based Memory (parallel branches)
- **Effort:** 10 hours
- **Benefit:** Ready for multi-agent expansion

### Tier 3c: Nice-to-Have (Optional)
- **3-3:** Bash Sandboxes (documentation only)
- **3-5:** Rippable Middleware (feature flags)
- **3-6:** Harness Versioning (A/B testing)
- **3-8:** Web Search / MCP (real-time knowledge)
- **Effort:** 7 hours
- **Benefit:** Advanced scenarios; research-grade

---

## Feature Details

### 3-1: P2-3 AI Auditors & Collaboration [Tier 3a]

**Remediation Level:** Heavy  
**Prevention Active:** "Prevent Evaluation Overfitting" — single agent without secondary review  
**Use Case:** Enterprise deployments; high-stakes decisions

#### Architecture

```
Primary Agent (Test Administrator)
  ↓ (submits output to)
Secondary Agent (AI Auditor)
  ├─ Validates correctness
  ├─ Checks for bias
  ├─ Identifies edge cases
  └─ Provides feedback
  ↓ (returns verdict: approved/rejected)
Primary Agent (accepts/revises)
  ↓ (submits final report)
```

#### Implementation Steps

1. **Create `.agent/auditors/qa-auditor.md`** — Secondary agent definition
   ```markdown
   # QA Auditor Agent

   **Role:** Review primary agent's test administration
   **Checks:**
   - All 50 questions presented (count = 50)
   - All 50 answers recorded (responses.length = 50)
   - No answer key revealed before Q50
   - Score calculation verified (correct / 50 × 100)
   - Domain breakdown logically sound
   - Recommendation justified by score
   ```

2. **Create audit validation flow in CLAUDE.md**
   ```markdown
   ## Secondary Review (P2-3) [Tier 3]

   After Q50 answered and score calculated:
   1. Package test state for auditor
   2. Submit to secondary agent for validation
   3. Auditor checks: completeness, integrity, calculation
   4. If approved: proceed to reporting
   5. If issues: flag for correction or escalation
   ```

3. **Add collaboration channels**
   - **Cooperative:** Auditor validates before merge
   - **Competitive:** Auditor proposes alternative recommendation; debate mechanism decides
   - **Coopetitive:** Agents negotiate on edge cases; reach consensus

4. **Implement Agent-as-a-Judge framework**
   - Dynamically evaluate harness performance
   - Prevent static benchmark overfitting
   - Evolving test suite as model improves

#### Benefits
- ✅ Secondary validation prevents hallucinations
- ✅ Catches edge cases and inconsistencies
- ✅ Provides audit trail for compliance
- ✅ Foundation for adversarial debate

#### Effort: 5 hours

---

### 3-2: P3-3 Pattern Auditing [Tier 3a]

**Remediation Level:** Medium  
**Prevention Active:** "Prevent Codebase Entropy" — dead code, circular dependencies accumulate  
**Use Case:** Long-term codebase maintenance; large-scale deployments

#### Implementation

1. **Create static analysis pipeline** (`.github/workflows/pattern-audit.yml`)
   ```yaml
   name: Pattern Auditing
   
   on:
     schedule:
       - cron: '0 2 * * 0'  # Weekly Sunday
     workflow_dispatch:
   
   jobs:
     audit:
       steps:
         - name: "Dead Code Detection"
           run: |
             # Scan for unused functions, variables, imports
             # Report unused_items.json
         
         - name: "Circular Dependency Check"
           run: |
             # Scan for circular imports
             # Report circular_deps.json
         
         - name: "Code Duplication"
           run: |
             # Find similar code blocks
             # Report duplicates.json
   ```

2. **Define audit criteria** in `docs/pattern-audit-schema.md`
   ```markdown
   # Pattern Audit Schema

   ## Dead Code Patterns
   - Unused functions (not called anywhere)
   - Unused variables (declared but never read)
   - Unused imports (imported but not used)
   - Unreachable code (after return statement)
   - TODO/FIXME comments (age > 30 days)

   ## Circular Dependencies
   - Module A imports B, B imports A
   - Chain: A → B → C → A
   - Transitive: A depends on B depends on C depends on A

   ## Code Duplication
   - Identical code blocks (> 20 lines, > 90% match)
   - Similar patterns (refactoring opportunity)
   - Copy-paste errors (likely bugs)
   ```

3. **Implement cleanup automation**
   - Generate cleanup report (`.session/pattern-audit-[date].json`)
   - Auto-remove unreachable code
   - Flag circular deps for manual review
   - Report duplication for refactoring

4. **Add to consolidation pipeline**
   - Merge pattern audit into weekly consolidation
   - Track metrics over time (dead code trend)
   - Alert if metrics degrade

#### Benefits
- ✅ Prevents dead code accumulation
- ✅ Detects architectural issues early
- ✅ Enables proactive maintenance
- ✅ Continuous health monitoring

#### Effort: 3 hours

---

### 3-3: P0-1 Bash Sandboxes [Tier 3c]

**Remediation Level:** Light  
**Prevention Active:** N/A (already provided by Claude Code)  
**Use Case:** Documentation; explicit constraint clarity

#### Implementation

Simply document in `docs/sandbox-specification.md`:

```markdown
# Bash Sandbox Specification (P0-1)

## Execution Environment

The CCAT Test Harness runs in Claude Code's isolated bash sandbox:
- **Isolation:** Per-session, no access to host system
- **Runtimes:** Node.js 14+, Python 3.8+, bash 5+
- **Filesystem:** Isolated from host
- **Network:** No outbound network access
- **System:** No system-level modifications

## Constraints Enforced

By sandbox:
- Cannot access files outside working directory
- Cannot modify system files
- Cannot execute arbitrary commands
- Cannot make external network calls

This prevents malicious or accidental damage to the host system.
```

#### Effort: 0.5 hours (documentation only)

---

### 3-4: P0-5 Orchestration Logic [Tier 3b]

**Remediation Level:** Heavy  
**Prevention Active:** "Prevent Coordinator Bottlenecks" — multi-agent system coordination  
**Use Case:** Multi-agent expansion; parallel test administration

#### Architecture (for Future MAS)

```
Supervisor Agent (Coordinator)
  ├─ Question Loader Agent
  │  └─ Loads 50 questions
  │  └─ Validates format
  │
  ├─ Question Presenter Agent
  │  └─ Presents Q1-Q50
  │  └─ Records responses
  │
  ├─ Scoring Agent
  │  └─ Compares to answer key
  │  └─ Calculates score
  │
  └─ Report Generator Agent
     └─ Creates summary
     └─ Provides recommendation

Communication: Supervisor routes tasks via .agent/mailbox/
```

#### Implementation

1. **Create supervisor pattern** (`.agent/orchestration/supervisor.md`)
2. **Define task routing logic** (which agent handles what)
3. **Implement handoff protocol** (how agents pass work)
4. **Add timeout and retry logic** (fault tolerance)
5. **Document topology choices** (why this pattern)

#### Benefit: Ready for multi-agent expansion without rearchitecture

#### Effort: 5 hours

---

### 3-5: P0-6 Rippable Middleware [Tier 3c]

**Remediation Level:** Light  
**Prevention Active:** "Prevent Over-Engineering" — gracefully remove obsolete logic  
**Use Case:** As models improve, remove safeguards that become unnecessary

#### Implementation

Create feature flag system in `CLAUDE.md` §21:

```markdown
## Rippable Middleware (P0-6) [Tier 3]

### Feature Flags

Define in `.agent/middleware-flags.json`:

{
  "FEATURE_SOCRATIC_QUESTIONING": {
    "enabled": true,
    "rationale": "Resolve ambiguities before test",
    "removal_condition": "Agent demonstrates 100% clarity without questioning",
    "removal_date": null
  },
  "FEATURE_STATE_CHECKPOINTS": {
    "enabled": true,
    "rationale": "Recover from context resets",
    "removal_condition": "Context window limits no longer a concern (16K+ tokens standard)",
    "removal_date": null
  },
  "FEATURE_ESCALATION_GATES": {
    "enabled": true,
    "rationale": "Prevent agent mistakes",
    "removal_condition": "Agent error rate < 0.1%",
    "removal_date": null
  }
}
```

### Graceful Removal Protocol

1. **Mark as "deprecated"** — flag known for sunset
2. **Log removal decision** — decision record in ANCHORS.md
3. **Remove with test** — ensure removal doesn't break system
4. **Archive logic** — keep old code in git history

#### Effort: 2 hours

---

### 3-6: P0-8 Harness Versioning [Tier 3c]

**Remediation Level:** Light  
**Prevention Active:** N/A (maturity amplifier)  
**Use Case:** A/B testing; performance comparison across versions

#### Implementation

1. **Define versioning scheme** in `docs/versioning.md`
   ```markdown
   # Harness Versioning

   Format: MAJOR.MINOR.PATCH

   - MAJOR: Breaking changes (e.g., new agent model)
   - MINOR: New features (e.g., new Tier features)
   - PATCH: Bug fixes, optimizations

   Examples:
   - v1.0.0 (Tier 1 + Tier 2)
   - v1.1.0 (add Tier 3a features)
   - v1.1.1 (bug fix)
   ```

2. **Track performance per version**
   ```json
   {
     "harness_version": "v1.0.0",
     "test_runs": 10,
     "avg_completion_time": "14:23",
     "context_resets": 0,
     "avg_score": 82.5,
     "reliability": 100
   }
   ```

3. **A/B testing framework**
   - Run test with v1.0.0
   - Run test with v1.1.0
   - Compare metrics
   - Decide on rollout

#### Effort: 1.5 hours

---

### 3-7: P0-10 Inter-Agent Communication [Tier 3b]

**Remediation Level:** Heavy  
**Prevention Active:** "Prevent Quadratic Coordination Overhead"  
**Use Case:** Multi-agent systems; parallel agent coordination

#### Architecture

```
Agent A          Agent B
  │                │
  └──→ Mailbox ←──┘
        ├── .agent/mailbox/to-agent-b.jsonl
        ├── .agent/mailbox/to-agent-a.jsonl
        └── .agent/mailbox/broadcast.jsonl
```

#### Implementation

1. **Message schema** (`.agent/mailbox/schema.json`)
   ```json
   {
     "type": "message",
     "from": "agent-id",
     "to": "agent-id | *",
     "timestamp": "ISO 8601",
     "priority": "high | normal | low",
     "payload": { ... },
     "ack_required": true
   }
   ```

2. **Mailbox operations**
   - `send(to_agent, message)` — P2P message
   - `broadcast(message)` — swarm message
   - `receive(agent_id)` — read messages for agent
   - `acknowledge(message_id)` — confirm receipt

3. **Deduplication & ordering**
   - Prevent duplicate processing
   - Maintain FIFO ordering
   - Clean up old messages (> 1 hour)

#### Benefit: Foundation for multi-agent coordination

#### Effort: 6 hours

---

### 3-8: P1-6 Web Search / MCP [Tier 3c]

**Remediation Level:** Light  
**Prevention Active:** N/A (context enhancement)  
**Use Case:** Dynamic test content; access to current data

#### Implementation

1. **Add web search capability** (optional)
   ```markdown
   # Web Search Integration (P1-6) [Tier 3]

   If test questions reference current events or data:
   - Enable web search tool
   - Search for latest information
   - Provide current answers to questions
   ```

2. **MCP (Model Context Protocol) integration**
   - Connect to external knowledge sources
   - Real-time data access
   - Domain-specific APIs

#### Note: For CCAT, this is low priority since test is self-contained.

#### Effort: 1.5 hours

---

### 3-9: P1-9 Branch-Based Cognitive Memory [Tier 3b]

**Remediation Level:** Medium  
**Prevention Active:** N/A (execution optimization)  
**Use Case:** Parallel task execution; complex branching logic

#### Architecture

```
Main Branch (Test Execution)
  ├─ Feature Branch A (Parallel Scoring Task)
  │  └─ Solve independently
  │  └─ Merge back with results
  │
  └─ Feature Branch B (Parallel Report Generation)
     └─ Solve independently
     └─ Merge back with results
```

#### Implementation

1. **Git worktree system** (`.agent/worktrees/`)
   ```bash
   git worktree add .agent/worktrees/score-branch
   # Agent A works here
   git commit -m "scores: calculate domain breakdown"
   git checkout main && git merge worktrees/score-branch
   ```

2. **Commit as memory**
   ```
   Main memory: Q1-Q50 executed sequentially
   
   Memory checkpoint (Q10):
   - Commit: "checkpoint: Q1-Q10 complete, 80% score"
   - Parents: Git history == cognitive memory
   ```

3. **Parallel subtask coordination**
   - Split test into 5 branches (Q1-Q10, Q11-Q20, etc.)
   - Execute in parallel
   - Merge results
   - Aggregate score

#### Benefit: Parallel execution for large-scale tests; advanced use case

#### Effort: 4 hours

---

## Tier 3 Implementation Schedule

### Phase 1: High-Impact (Week 3.1)
- **3-1:** AI Auditors — 5 hours
- **3-2:** Pattern Auditing — 3 hours
- **Subtotal:** 8 hours
- **Outcome:** Production-grade quality assurance

### Phase 2: MAS Foundation (Week 3.2)
- **3-4:** Orchestration — 5 hours
- **3-7:** Inter-Agent Communication — 6 hours
- **3-9:** Branch-Based Memory — 4 hours
- **Subtotal:** 15 hours
- **Outcome:** Ready for multi-agent expansion

### Phase 3: Nice-to-Have (Week 3.3)
- **3-3:** Bash Sandboxes — 0.5 hours
- **3-5:** Rippable Middleware — 2 hours
- **3-6:** Harness Versioning — 1.5 hours
- **3-8:** Web Search / MCP — 1.5 hours
- **Subtotal:** 5.5 hours
- **Outcome:** Advanced scenarios; research-grade

---

## Final Maturity Progression

```
Current (Tier 1 + 2):
├─ Foundation: 5/10 (Git, Verification, Escalation, Wrappers, Ralph)
├─ Context: 9/11 (All except Web Search, Branch Memory)
├─ Constraints: 4/5 (Intake, Bounded Access, Linters, Dependency)
└─ Entropy: 4/4 (Consolidation, Cleanup, Doc Sync, Pattern Audit pending)
→ Total: 21/30 (70%)

After Tier 3:
├─ Foundation: 10/10 (+ Bash Sandboxes, Orchestration, Middleware, Versioning, Mailbox)
├─ Context: 11/11 (+ Web Search, Branch Memory)
├─ Constraints: 5/5 (+ AI Auditors)
└─ Entropy: 4/4 (+ Pattern Audit completion)
→ Total: 30/30 (100%) ✨ COMPLETE
```

---

## Decision Matrix

| When to Implement | Features | Effort | Benefit |
|---|---|---|---|
| **High Priority** | 3-1 (AI Auditors), 3-2 (Pattern Audit) | 8 hrs | Enterprise quality |
| **MAS Ready** | 3-4, 3-7, 3-9 | 15 hrs | Multi-agent foundation |
| **Optional** | 3-3, 3-5, 3-6, 3-8 | 5.5 hrs | Advanced scenarios |

---

## Recommendation

**Current Status:** Tier 2 is production-complete (70% maturity)

**Next Steps (Choose One):**

1. **Deploy Tier 2 as-is** → Begin test execution immediately
2. **Implement Tier 3a** (8 hours) → Add AI auditors + pattern audit for enterprise
3. **Implement Tier 3b** (15 hours) → Prepare for multi-agent expansion
4. **Implement Full Tier 3** (25 hours) → 100% maturity; research-grade system

---

**Status:** Planning phase (not yet executed)  
**Estimated Total Effort:** 15-25 hours  
**Expected Completion:** Week 3+ (contingent on priority)  
**Target Maturity:** 100% (30/30 features)

---

## References

- **HE-TIER2-PLAN.md** — Current Tier 2 (in progress)
- **HE-SCOPE.md** — Audit baseline and context
- **CLAUDE.md** — Agent context documentation
- **HE-PRIORITIES.md** — Gap prioritization matrix

---

**Prepared by:** Claude Code (Harness Engineering)  
**Date:** 2026-04-05  
**Version:** v1.0.0 (Planning)  
**Status:** Ready for decision on Tier 3 scope
