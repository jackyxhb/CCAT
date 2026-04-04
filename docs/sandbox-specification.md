# Bash Sandbox Specification (P0-1)

**Feature:** P0-1 (Bash Sandboxes)  
**Tier:** Tier 3 (Nice-to-Have)  
**Purpose:** Document execution environment constraints  
**Status:** Documentation Only

---

## Execution Environment

The CCAT Test Harness runs in Claude Code's isolated bash sandbox with the following characteristics:

### Isolation

- **Per-Session Isolation:** Each session runs in a separate sandbox
- **No Host Access:** Cannot access files outside working directory
- **No Persistence:** Sandbox destroyed after session ends (except git commits)
- **Resource Limits:** CPU, memory, disk I/O bounded

### Runtimes Available

- **Node.js:** 14+ (for future MAS agents)
- **Python:** 3.8+ (for analysis scripts)
- **Bash:** 5.0+ (for shell operations)
- **Git:** 2.30+ (for version control)

### Filesystem Access

- **Readable:** Working directory and subdirectories (recursive)
- **Writable:** `.session/`, `.agent/`, `.github/` (project directories only)
- **Blocked:** `~/.ssh`, `~/.aws`, `/etc`, `/root` (system directories)

### Network Access

- **Outbound:** Not allowed by default
- **Inbound:** Not applicable
- **Exception:** Web search tool available if explicitly enabled

### System Modifications

- **Process Control:** Can spawn child processes (python, node, bash scripts)
- **Environment:** Can read/set environment variables (within sandbox)
- **System Calls:** Limited to sandbox-safe operations
- **Service Start:** Cannot start background services or daemons

---

## Constraints Enforced by Sandbox

The sandbox automatically prevents:

| Operation | Prevention | Reason |
|-----------|-----------|--------|
| Escape filesystem | Chroot/sandbox | Cannot cd outside working dir |
| Modify system files | Permissions | No write to `/etc`, `/root`, etc. |
| Execute arbitrary binaries | Whitelist | Only safe binaries allowed |
| Make network calls | Firewall | No outbound network |
| Access secrets | Isolation | No access to `~/.ssh`, `~/.aws` |
| Open privileged ports | Permissions | Ports < 1024 require root |

---

## Benefits for CCAT Harness

✅ **Safety:** Protects against accidental or malicious damage  
✅ **Isolation:** Each test session independent  
✅ **Reproducibility:** Consistent environment across runs  
✅ **Auditability:** All operations logged by sandbox  
✅ **Compliance:** Safe for production deployments

---

**Status:** Documented (Tier 3 P0-1)  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
