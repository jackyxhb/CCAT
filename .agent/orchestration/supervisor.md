# Supervisor Agent — Orchestration Pattern

**Tier:** Tier 3 (Advanced)  
**Feature:** P0-5 (Orchestration Logic)  
**Role:** Coordinate multi-agent task execution  
**Status:** Foundation Ready (MAS Preparation)

---

## Overview

The Supervisor Agent orchestrates multi-agent system (MAS) execution by managing task routing, agent lifecycle, handoffs, and failure recovery.

**When:** MAS expansion (future phase)  
**Who:** Supervisor coordinates 4+ worker agents  
**What:** Route tasks, manage communication, handle escalations  
**How:** Mailbox-based message passing + state serialization

---

## Current Architecture (SAS)

```
User → CCAT Test Orchestrator → User
        (monolithic agent)
```

## Future Architecture (MAS)

```
                   Supervisor
                       │
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
     Question       Question      Scorer
     Loader       Presenter       Agent
     Agent        Agent              │
         │             │             │
         ├─ Load Q1-50  ├─ Present Q  ├─ Score responses
         ├─ Validate    ├─ Record ans ├─ Calc breakdown
         └─ Output list └─ Continue   └─ Output score
         
     Report
     Generator
         │
         ├─ Receive score
         ├─ Create report
         └─ Output: final report
```

---

## Supervisor Responsibilities

### 1. Task Initialization

**Responsibility:** Start worker agents and initialize task queue

```
Supervisor:
  1. Spawn Agent 1 (Question Loader)
     └─ Timeout: 30 sec
  2. Spawn Agent 2 (Question Presenter)
     └─ Timeout: none (interactive)
  3. Spawn Agent 3 (Scorer)
     └─ Timeout: 5 min per batch
  4. Spawn Agent 4 (Report Generator)
     └─ Timeout: 1 min
  5. Initialize .agent/mailbox/ directories
  6. Create task queue: question_loader → question_presenter → scorer → report_generator
```

### 2. Task Routing

**Responsibility:** Route completed tasks to next agent in pipeline

```
Task Flow:
  Question Loader completes
    → Output: { questions[], answer_key[] }
    → Supervisor receives output
    → Routes to Question Presenter
    → Sets message: "questions_loaded"

Question Presenter presents Q1-Q50
    → After each question: { question_id, user_response }
    → Supervisor collects responses
    → After Q50: Routes batch to Scorer

Scorer processes batch
    → Output: { score_pct, domain_breakdown }
    → Supervisor receives
    → Routes to Report Generator

Report Generator creates report
    → Output: formatted_report
    → Supervisor receives
    → Returns to User
```

### 3. Agent Communication

**Responsibility:** Manage message passing between agents via mailbox

Mailbox Structure:
```
.agent/mailbox/
  ├─ to-loader.jsonl
  │   └─ Messages for Question Loader
  ├─ to-presenter.jsonl
  │   └─ Messages for Question Presenter
  ├─ to-scorer.jsonl
  │   └─ Messages for Scorer
  ├─ to-generator.jsonl
  │   └─ Messages for Report Generator
  └─ broadcast.jsonl
      └─ Supervisor announcements (all agents)
```

**Message Protocol:**
```json
{
  "type": "task",
  "from": "supervisor",
  "to": "agent-id",
  "timestamp": "ISO 8601",
  "priority": "high|normal|low",
  "payload": { "task": "...", "data": {...} },
  "ack_required": true,
  "message_id": "msg-uuid"
}
```

### 4. Handoff Management

**Responsibility:** Ensure work passes cleanly between agents

Handoff Protocol:
```
Agent A completes task:
  1. Write output to .session/handoff-[agent-id].json
  2. Send message to Supervisor: "task_complete"
  3. Await acknowledgment from Supervisor

Supervisor receives completion:
  1. Validate output format
  2. Check for errors or anomalies
  3. If OK: acknowledge + pass to Agent B
  4. If error: escalate or retry (max 3x)
  5. Send message to Agent B: "task_start" + input data

Agent B receives message:
  1. Acknowledge receipt (set ack = true)
  2. Load input data from previous agent
  3. Begin processing
  4. Repeat cycle
```

### 5. Timeout & Retry Logic

**Responsibility:** Detect hung agents and retry failed operations

Timeout Rules:
```
Question Loader: 30 sec (load questions, validate format)
Question Presenter: None (interactive with user)
Scorer: 5 min (process responses, calc score)
Report Generator: 1 min (generate report)

If agent exceeds timeout:
  1. Log "timeout_detected" event
  2. Send "cancel_task" message
  3. Attempt restart (max 2 retries)
  4. If still failing: escalate to human

Retry Strategy:
  1. On failure: backoff 5 sec, retry
  2. On 2nd failure: backoff 10 sec, retry
  3. On 3rd failure: escalate to human
```

### 6. State Management

**Responsibility:** Maintain supervisor state across context resets

Supervisor State:
```json
{
  "session_id": "ccat-2026-04-05-120000",
  "status": "running|paused|completed",
  "current_stage": "loading|presenting|scoring|reporting",
  "agents": {
    "loader": { "status": "complete", "output_size": 1024 },
    "presenter": { "status": "running_q_25", "responses_count": 25 },
    "scorer": { "status": "pending", "input_size": 0 },
    "generator": { "status": "pending", "input_size": 0 }
  },
  "task_queue": [
    { "agent": "presenter", "status": "in_progress", "progress": "25/50" },
    { "agent": "scorer", "status": "queued" },
    { "agent": "generator", "status": "queued" }
  ],
  "checkpoint": "Q25",
  "context_resets": 0
}
```

Stored at: `.session/supervisor-state.json`

Recovery Protocol (on context reset):
```
1. Load .session/supervisor-state.json
2. Identify last completed stage
3. Determine next agent to activate
4. Resume from checkpoint
5. Increment context_resets counter
```

### 7. Escalation Handling

**Responsibility:** Detect critical errors and escalate to human

Escalation Conditions:
```
CRITICAL (escalate immediately):
  - Agent crash or non-responsive (> 2 retries)
  - Answer key compromise detected
  - Scoring inconsistency found
  - Audit validation failed

ERROR (retry then escalate):
  - Message delivery failure
  - Handoff validation failed
  - Data format corruption
  - Timeout exceeded (3 retries)

WARNING (log and continue):
  - Slow processing (> expected time)
  - Agent producing warnings
  - Audit issues detected
```

---

## Task Routing Configuration

### Routing Table

| Stage | Source Agent | Target Agent | Payload | Timeout |
|-------|---|---|---|---|
| **1** | init | Question Loader | none | 30 sec |
| **2** | Loader | Presenter | questions[], answer_key[] | none |
| **3** | Presenter | Scorer | responses[] | 5 min |
| **4** | Scorer | Generator | score_pct, domains[] | 1 min |
| **5** | Generator | Supervisor | report[] | - |

### Agent Configuration

```yaml
agents:
  question_loader:
    timeout: 30s
    max_retries: 2
    on_failure: escalate
  
  question_presenter:
    timeout: null  # interactive
    max_retries: 0  # don't retry (user interaction)
    on_failure: escalate
  
  scorer:
    timeout: 5m
    max_retries: 2
    on_failure: escalate
  
  report_generator:
    timeout: 1m
    max_retries: 2
    on_failure: escalate
```

---

## Supervisor Implementation Steps

### Step 1: Supervisor Bootstrap (immediate)

Create `.agent/orchestration/supervisor-bootstrap.sh`:
```bash
#!/bin/bash
# Initialize supervisor
mkdir -p .agent/mailbox
mkdir -p .session/handoff-points

# Create initial state
jq -n '{session_id: env.SESSION_ID, status: "init"}' > .session/supervisor-state.json

echo "✓ Supervisor initialized"
```

### Step 2: Agent Spawning (future MAS)

When MAS activates:
```bash
# Spawn agents (would run in separate sessions/contexts)
spawn_agent "question-loader" &
spawn_agent "question-presenter" &
spawn_agent "scorer" &
spawn_agent "report-generator" &

wait_all_agents  # Wait for completion
```

### Step 3: Message Passing (future MAS)

Supervisor routes messages via mailbox:
```bash
# Send task to next agent
send_message "to-question-presenter.jsonl" \
  '{"type":"task","payload":{"questions":[...]}}'

# Wait for response
wait_for_message "question-presenter" "task_complete"

# Acknowledge receipt
acknowledge_message "msg-id"
```

### Step 4: Failover & Recovery (future MAS)

On agent failure:
```bash
detect_agent_failure "scorer"  # Detect timeout or crash

if [ $retries -lt 3 ]; then
  respawn_agent "scorer"       # Restart agent
  retry_task "scorer"          # Retry task
else
  escalate_to_human            # Give up, ask human
fi
```

---

## Design Decisions

### Why Sequential Handoff (Not Parallel)?

**Sequential Pattern:**
```
Q Loader → Q Presenter → Scorer → Q Generator
```

**Why Not Parallel?**
- Questions depend on Question Loader output
- Presenter must present questions in order (Q1-Q50)
- Scorer must wait for all 50 responses (Q1-Q50)
- Reporter waits for final score

**When Parallel Makes Sense:**
- Multiple test administrations (Test A, Test B, Test C in parallel)
- Domain scoring (Verbal, Quantitative, Spatial in parallel)
- Future: A/B testing (version 1.0 vs 1.1 parallel runs)

### Why Filesystem-Based Mailbox (Not Memory)?

**Filesystem:**
- ✅ Survives context resets (persistent)
- ✅ Auditable (full message history)
- ✅ Debuggable (can inspect messages)
- ❌ Slower than in-memory

**Memory:**
- ✅ Fast
- ❌ Lost on context reset
- ❌ Can't audit or inspect

**Choice: Filesystem** (for test harness reliability > speed)

### Why 3-Retry Limit?

**Exponential Backoff:**
- 1st retry: 5 sec backoff
- 2nd retry: 10 sec backoff
- 3rd failure: escalate

**Why 3?**
- Handles transient failures (network blip, resource spike)
- Prevents infinite loops
- Still catches real failures quickly (30 sec total)

---

## Future: Orchestration Modes

### Mode 1: Sequential (Current)
```
Agent1 → Agent2 → Agent3 → Agent4
```
Use: Linear task pipelines (test administration)

### Mode 2: Parallel with Merge
```
Agent1 → (Agent2a, Agent2b, Agent2c) → Agent4
         Merge branch
```
Use: Parallel scoring domains, then aggregate

### Mode 3: Branching & Negotiation
```
Agent1 → Agent2 → (Agent3a, Agent3b) → Debate → Agent4
                   Competitive modes
```
Use: Adversarial review (competing auditors)

---

## References

- **AGENTS.md** — Agent definitions
- **CLAUDE.md §23** — Orchestration section (will be added)
- **mailbox/schema.json** — Message format (P0-10)
- **HE-TIER3-PLAN.md** — Orchestration specification

---

**Status:** Foundation Ready (Tier 3 P0-5)  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
