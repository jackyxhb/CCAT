# Inter-Agent Communication (P0-10)

**Feature:** P0-10 (Inter-Agent Communication)  
**Tier:** Tier 3 (Advanced)  
**Purpose:** Enable reliable message passing between autonomous agents in MAS  
**Status:** Foundation Ready

---

## Mailbox System Overview

The mailbox system enables asynchronous, reliable communication between agents in a multi-agent system (MAS) without shared memory.

### Architecture

```
Agent A                         Agent B
  │ send_message()              │
  ├─ create message             │
  ├─ assign message_id          │
  └─ write to mailbox ──────────┤
                                ├─ read mailbox
                                ├─ process message
                                └─ send ack

Agent B                         Agent A
  │ send_ack()                  │
  ├─ create ack message         │
  ├─ set ack_message_id         │
  └─ write to mailbox ──────────┤
                                ├─ receive ack
                                └─ mark message delivered
```

### File Structure

```
.agent/mailbox/
├── schema.json
├── README.md (this file)
├── to-supervisor.jsonl
├── to-auditor-qa-01.jsonl
├── to-question-loader.jsonl
├── to-question-presenter.jsonl
├── to-scorer.jsonl
├── to-report-generator.jsonl
├── broadcast.jsonl
└── archive/
    ├── to-*.jsonl.[YYYY-MM-DD].bak
    └── delivered-messages.jsonl
```

---

## Message Types

### 1. Task Message

Supervisor assigns work to an agent.

```json
{
  "type": "task",
  "from": "supervisor",
  "to": "question-loader",
  "timestamp": "2026-04-05T12:00:00.000Z",
  "priority": "high",
  "payload": {
    "task": "load_questions",
    "task_id": "task-q-001",
    "data": {
      "question_source": "CCAT_TEST_META_RULES.md",
      "expected_count": 50
    }
  },
  "message_id": "msg-12345678-1234-1234-1234-123456789abc",
  "ack_required": true,
  "expires_at": "2026-04-05T12:00:30.000Z"
}
```

**Used For:**
- Assigning tasks to agents
- Passing input data between agents
- Requesting status updates
- Issuing commands

---

### 2. Message Type

General communication between agents (status updates, results, notifications).

```json
{
  "type": "message",
  "from": "question-loader",
  "to": "supervisor",
  "timestamp": "2026-04-05T12:00:05.000Z",
  "payload": {
    "task": "load_questions_complete",
    "task_id": "task-q-001",
    "data": {
      "questions_loaded": 50,
      "answer_key_loaded": true
    }
  },
  "message_id": "msg-87654321-4321-4321-4321-cba987654321",
  "ack_required": true
}
```

**Used For:**
- Task completion notifications
- Status updates
- Error reports
- Data handoffs

---

### 3. Acknowledgment (ACK)

Receiver acknowledges receipt of message.

```json
{
  "type": "ack",
  "from": "supervisor",
  "to": "question-loader",
  "timestamp": "2026-04-05T12:00:06.000Z",
  "payload": {},
  "message_id": "msg-aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
  "ack_message_id": "msg-87654321-4321-4321-4321-cba987654321",
  "status": "delivered"
}
```

**Purpose:**
- Confirms message was received
- Indicates processing status
- Enables reliable delivery tracking

---

### 4. Negative Acknowledgment (NACK)

Receiver indicates message could not be processed.

```json
{
  "type": "nack",
  "from": "scorer",
  "to": "supervisor",
  "timestamp": "2026-04-05T12:05:00.000Z",
  "payload": {
    "error": "Invalid response format: missing question_id",
    "details": "Response index 3 missing required field"
  },
  "message_id": "msg-bbbbbbbb-cccc-dddd-eeee-ffffffffffff",
  "ack_message_id": "msg-12345678-5678-9abc-def0-123456789abc",
  "status": "failed"
}
```

**Used For:**
- Reporting processing errors
- Requesting message resend
- Indicating agent failure
- Escalation triggers

---

### 5. Broadcast

Supervisor sends announcement to all agents.

```json
{
  "type": "broadcast",
  "from": "supervisor",
  "to": "broadcast",
  "timestamp": "2026-04-05T12:10:00.000Z",
  "priority": "high",
  "payload": {
    "task": "context_reset_alert",
    "data": {
      "context_window": 2,
      "checkpoint": "Q25",
      "action": "all_agents_pause_and_wait_for_reinjection"
    }
  },
  "message_id": "msg-ffffffff-0000-1111-2222-333333333333",
  "ack_required": false
}
```

**Used For:**
- System-wide announcements
- Context reset alerts
- Shutdown signals
- Status broadcasts

---

## Mailbox Operations

### 1. Send Message

**Function:** `send(to_agent, message)`

```bash
# Create message with UUID
MESSAGE_ID="msg-$(uuidgen | tr '[:upper:]' '[:lower:]')"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# Write to recipient's mailbox
cat > ".agent/mailbox/to-${TO_AGENT}.jsonl" << EOF
{
  "type": "task",
  "from": "supervisor",
  "to": "${TO_AGENT}",
  "timestamp": "${TIMESTAMP}",
  "priority": "normal",
  "payload": { ... },
  "message_id": "${MESSAGE_ID}",
  "ack_required": true
}
EOF

echo "✓ Message sent to ${TO_AGENT}: ${MESSAGE_ID}"
```

---

### 2. Receive Message

**Function:** `receive(agent_id)`

```bash
# Read messages for this agent (FIFO order)
if [ -f ".agent/mailbox/to-${AGENT_ID}.jsonl" ]; then
  # Read first line (oldest message)
  MESSAGE=$(head -n1 ".agent/mailbox/to-${AGENT_ID}.jsonl")
  
  # Extract message_id and type
  MSG_ID=$(echo "$MESSAGE" | jq -r '.message_id')
  MSG_TYPE=$(echo "$MESSAGE" | jq -r '.type')
  
  echo "✓ Received: ${MSG_TYPE} (${MSG_ID})"
  
  # Process message
  process_message "$MESSAGE"
  
  # Remove from mailbox (after processing)
  tail -n +2 ".agent/mailbox/to-${AGENT_ID}.jsonl" > temp && \
    mv temp ".agent/mailbox/to-${AGENT_ID}.jsonl"
else
  echo "ℹ No messages for ${AGENT_ID}"
fi
```

---

### 3. Acknowledge Receipt

**Function:** `acknowledge(message_id)`

```bash
# Create ACK message
ACK_MSG_ID="msg-$(uuidgen | tr '[:upper:]' '[:lower:]')"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# Write ACK to sender's mailbox
cat > ".agent/mailbox/to-${SENDER_AGENT}.jsonl" << EOF
{
  "type": "ack",
  "from": "${MY_AGENT_ID}",
  "to": "${SENDER_AGENT}",
  "timestamp": "${TIMESTAMP}",
  "payload": {},
  "message_id": "${ACK_MSG_ID}",
  "ack_message_id": "${ORIGINAL_MESSAGE_ID}",
  "status": "delivered"
}
EOF

echo "✓ Acknowledgment sent for: ${ORIGINAL_MESSAGE_ID}"
```

---

### 4. Check Message Status

**Function:** `check_status(message_id)`

```bash
# Search all mailboxes for message or its ACK
for mailbox in .agent/mailbox/to-*.jsonl broadcast.jsonl; do
  if grep -q "\"ack_message_id\": \"${MESSAGE_ID}\"" "$mailbox"; then
    echo "✓ ACK received: message delivered"
    return 0
  fi
done

echo "⏳ Awaiting ACK for: ${MESSAGE_ID}"
return 1
```

---

## Deduplication & Ordering

### Deduplication

**Problem:** Network retries might cause duplicate messages.

**Solution:** Track seen message_ids

```bash
# Maintain seen messages in .session/seen-messages.json
SEEN_FILE=".session/seen-messages.json"

if grep -q "\"${MESSAGE_ID}\"" "$SEEN_FILE"; then
  echo "✗ DUPLICATE: Message already processed (${MESSAGE_ID})"
  return 1
else
  # Add to seen messages
  jq ". += [\"${MESSAGE_ID}\"]" "$SEEN_FILE" > temp && \
    mv temp "$SEEN_FILE"
  echo "✓ Message is fresh (${MESSAGE_ID})"
fi
```

### FIFO Ordering

**Requirement:** Messages processed in order received (per recipient).

**Mechanism:** Each mailbox is a JSONL file (append-only, line-based).

```
to-scorer.jsonl:
Line 1: { "type": "task", "payload": { "data": { "responses": [1-25] } }, ... }  ← Process 1st
Line 2: { "type": "task", "payload": { "data": { "responses": [26-50] } }, ... }  ← Process 2nd
Line 3: { "type": "message", ... }  ← Process 3rd
```

**Reading (FIFO):**
```bash
# Process oldest message first (head -n1)
oldest_msg=$(head -n1 ".agent/mailbox/to-${AGENT}.jsonl")
process_msg "$oldest_msg"

# Remove oldest, shift remaining up
tail -n +2 ".agent/mailbox/to-${AGENT}.jsonl" > temp && \
  mv temp ".agent/mailbox/to-${AGENT}.jsonl"
```

---

## Message Cleanup

### Automatic Cleanup

**Policy:** Delete messages older than 1 hour

```bash
# Run daily (can be part of cleanup.yml)
CUTOFF_TIME=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)

for mailbox in .agent/mailbox/to-*.jsonl; do
  # Remove old messages
  jq "select(.timestamp > \"${CUTOFF_TIME}\")" "$mailbox" > temp && \
    mv temp "$mailbox"
done

echo "✓ Message cleanup complete"
```

### Archive Old Messages

**Storage:** Move delivered messages to archive

```bash
# Archive delivered messages (> 1 hour old)
cat .agent/mailbox/to-*.jsonl | \
  jq 'select(.status == "delivered") | select(.timestamp < "2026-04-05T11:00:00Z")' \
  >> .agent/mailbox/archive/delivered-messages.jsonl

# Remove from live mailbox
jq 'select(.status != "delivered" or .timestamp >= "2026-04-05T11:00:00Z")' \
  .agent/mailbox/to-*.jsonl > temp && \
  mv temp .agent/mailbox/to-*.jsonl
```

---

## Error Handling

### Delivery Failure

**Scenario:** Message not ACKed within timeout

```bash
# Check for unACKed messages
timeout_sec=30
for msg in $(jq -r '.message_id' .agent/mailbox/to-*.jsonl); do
  age_sec=$(($(date +%s) - $(grep "$msg" .agent/mailbox/to-*.jsonl | jq -r '.timestamp | sub("Z"; "+00:00") | fromdate')))
  
  if [ $age_sec -gt $timeout_sec ] && ! has_ack "$msg"; then
    echo "✗ TIMEOUT: No ACK for ${msg} after ${timeout_sec}s"
    
    # Retry logic
    if [ $(get_retry_count "$msg") -lt 3 ]; then
      retry_message "$msg"
    else
      escalate_to_human "Message delivery failed: ${msg}"
    fi
  fi
done
```

### Processing Error

**Scenario:** Receiver reports NACK

```bash
# On receiving NACK
if msg_type=$(echo "$MSG" | jq -r '.type') && [ "$msg_type" == "nack" ]; then
  error=$(echo "$MSG" | jq -r '.payload.error')
  original_id=$(echo "$MSG" | jq -r '.ack_message_id')
  
  echo "✗ Processing failed: ${error}"
  
  # Determine action
  if [ "$error" == "Invalid response format" ]; then
    # Sender error - request retry with corrected data
    send_task "Resend with correct format"
  else
    # Receiver error - escalate
    escalate_to_human "Agent error: ${error}"
  fi
fi
```

---

## Integration with Supervisor

Supervisor uses mailbox for all agent communication:

```
1. Supervisor sends task to Loader
   └─ Message: { "type": "task", "to": "question-loader", ... }

2. Loader receives, acknowledges, starts work
   └─ Message: { "type": "ack", "from": "question-loader", ... }

3. Loader completes, sends result
   └─ Message: { "type": "message", "payload": { "data": {...} }, ... }

4. Supervisor acknowledges result, sends to next agent
   └─ Message: { "type": "ack", ... } + { "type": "task", "to": "question-presenter", ... }

5. Repeat until Q50 complete
```

---

## Example: Full Workflow

```
Supervisor                    Question Loader
    │
    ├─ send task ────────────→  to-question-loader.jsonl
    │  { load_questions }
    │
    │ ← send ack ──────────────  to-supervisor.jsonl
    │  { ack, msg-123 }
    │
    │
    │ ← send message ───────────  to-supervisor.jsonl
    │  { load_questions_complete, data: {questions[], answer_key[]} }
    │
    │
    ├─ process result
    │
    ├─ send ack ────────────→  to-question-loader.jsonl
    │  { ack, msg-456 }
    │
    └─ send to presenter ──→  to-question-presenter.jsonl
       { present_question, data: { questions[], ... } }
```

---

## References

- **schema.json** — Full message schema (JSON-Schema)
- **supervisor.md** — Supervisor orchestration (.agent/orchestration/)
- **CLAUDE.md §24** — Inter-agent communication section (will be added)
- **AGENTS.md** — Agent definitions

---

**Status:** Foundation Ready (Tier 3 P0-10)  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
