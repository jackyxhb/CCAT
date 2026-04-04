# Branch-Based Cognitive Memory (P1-9)

**Feature:** P1-9 (Branch-Based Memory)  
**Tier:** Tier 3 (Advanced)  
**Purpose:** Enable parallel task execution via git branches and worktrees  
**Status:** Foundation Ready

---

## Overview

Branch-based memory leverages git's branching and worktree capabilities to enable parallel task execution with automatic result merging and conflict resolution.

**Use Case:** Large-scale tests, parallel domain scoring, A/B testing variants  
**Mechanism:** Git worktrees for isolation + commits as memory checkpoints

---

## Architecture

### Single-Agent (Current)

```
Main Branch
├── Q1-Q10: executed sequentially
├── Q11-Q20: executed sequentially
├── Q21-Q30: executed sequentially
├── Q31-Q40: executed sequentially
└── Q41-Q50: executed sequentially

Memory: Git history (50 commits, one per question)
```

### Multi-Branch (Future)

```
Main Branch
├── Workbench (current work)
│   ├── Q1-Q10
│   ├── Q11-Q20
│   └── Control flow
│
├── Feature Branch 1: Verbal Scoring
│   ├── Score verbal domain Q1-Q50
│   ├── Calculate verbal %
│   └── Merge result: verbal_score = 85%
│
├── Feature Branch 2: Quant Scoring
│   ├── Score quant domain Q1-Q50
│   ├── Calculate quant %
│   └─ Merge result: quant_score = 78%
│
├── Feature Branch 3: Spatial Scoring
│   ├── Score spatial domain Q1-Q50
│   ├── Calculate spatial %
│   └─ Merge result: spatial_score = 82%
│
└── Final Branch: Report Generation
    ├── Aggregate domain scores
    ├── Create summary report
    └─ Publish final report
```

**Parallel Execution:**
- Main Branch: Execute Q1-Q50 sequentially (presenter)
- 3 Domain Branches: Calculate scores in parallel (no interdependency)
- Final Branch: Merge scores, generate report

---

## Git Worktree System

### Creating Worktrees

```bash
# Create isolated worktree for each parallel task
git worktree add .agent/worktrees/verbal-branch verbal-scoring
git worktree add .agent/worktrees/quant-branch quant-scoring
git worktree add .agent/worktrees/spatial-branch spatial-scoring

# Each worktree has:
# - Isolated git index
# - Separate HEAD pointer
# - Independent working directory
# - Can be checked out to different commits
```

### Worktree Structure

```
.agent/worktrees/
├── main/
│   └── (main branch work)
├── verbal-branch/
│   ├── .git -> points to main .git
│   ├── REQUIREMENTS.md
│   ├── test-results.json (verbal domain only)
│   └── verbal-score.json
├── quant-branch/
│   ├── .git -> points to main .git
│   ├── REQUIREMENTS.md
│   ├── test-results.json (quant domain only)
│   └── quant-score.json
└── spatial-branch/
    ├── .git -> points to main .git
    ├── REQUIREMENTS.md
    ├── test-results.json (spatial domain only)
    └── spatial-score.json
```

---

## Commit as Memory Checkpoints

### Single-Agent Memory

Each question creates a commit:

```bash
# After Q1 answered
git add .session/test-results.json
git commit -m "checkpoint: Q1 complete | Score: 100% | Time: 0:12"

# After Q10 answered
git add .session/test-results.json
git commit -m "checkpoint: Q10 complete | Score: 80% | Time: 1:23"

# Git history = cognitive memory of progress
$ git log --oneline
ca8c414 checkpoint: Q10 complete | Score: 80% | Time: 1:23
2b833f4 checkpoint: Q5 complete | Score: 100% | Time: 0:47
a1b2c3d checkpoint: Q1 complete | Score: 100% | Time: 0:12
```

### Multi-Branch Memory

Parallel branches maintain separate memories:

**Verbal Branch:**
```bash
cd .agent/worktrees/verbal-branch

# Process verbal questions only
for q in {1,2,3,4,5,7,9,12,15,18}; do  # Verbal questions
  score_question $q
  git add verbal-score.json
  git commit -m "verbal: Q$q scored | Running avg: 87%"
done

$ git log --oneline
msg-9a8b7c6 verbal: Q18 scored | Running avg: 87%
msg-8f7e6d5 verbal: Q15 scored | Running avg: 90%
msg-7c6b5a4 verbal: Q12 scored | Running avg: 92%
...
```

**Quant Branch:**
```bash
cd .agent/worktrees/quant-branch

# Process quant questions in parallel (no interdependency!)
for q in {6,8,10,11,13,14,16,17,19,20}; do  # Quant questions
  score_question $q
  git add quant-score.json
  git commit -m "quant: Q$q scored | Running avg: 76%"
done
```

---

## Parallel Execution Workflow

### Phase 1: Execution (Main + 3 Branches in Parallel)

```
Timeline:

T=0:00  Main Branch                Verbal Branch              Quant Branch               Spatial Branch
        └─ Start Q1                └─ Start scoring V         └─ Start scoring Q        └─ Start scoring S

T=0:05  └─ Q1 answered             └─ V1,V2 scored           └─ Q1,Q2 scored           └─ S1,S2 scored

T=0:10  └─ Q2 presented            └─ V3,V4 scored           └─ Q3,Q4 scored           └─ S3,S4 scored
        ...continues Q1-Q50        ...continues V scoring    ...continues Q scoring    ...continues S scoring
        (10-15 min)               (3-5 min parallel)         (3-5 min parallel)        (3-5 min parallel)

T=14:00 └─ Q50 answered           └─ All V scored ✓          └─ All Q scored ✓         └─ All S scored ✓
```

### Phase 2: Merge Results

**Step 1: Merge domain branches to main**
```bash
# From main branch
git checkout main
git merge verbal-scoring --no-edit
git merge quant-scoring --no-edit
git merge spatial-scoring --no-edit

# Merged state: all scores aggregated
git log --oneline | head -10
# Shows: "Merge branch verbal-scoring"
#        "Merge branch quant-scoring"
#        "Merge branch spatial-scoring"
```

**Step 2: Aggregate scores**
```bash
cd .agent/worktrees/report-branch

# Combine domain results
verbal_score=$(cat ../verbal-branch/verbal-score.json | jq '.avg_score')
quant_score=$(cat ../quant-branch/quant-score.json | jq '.avg_score')
spatial_score=$(cat ../spatial-branch/spatial-score.json | jq '.avg_score')

overall_score=$(( (verbal_score + quant_score + spatial_score) / 3 ))

# Create report commit
cat > report.json << EOF
{
  "overall_score": $overall_score,
  "domain_breakdown": {
    "verbal": $verbal_score,
    "quantitative": $quant_score,
    "spatial": $spatial_score
  }
}
EOF

git add report.json
git commit -m "report: final aggregation | Verbal: $verbal_score% | Quant: $quant_score% | Spatial: $spatial_score%"
```

**Step 3: Final merge to main**
```bash
git checkout main
git merge report-branch --no-edit

# Final state: all branches merged, all scores aggregated
$ git log --oneline | head -5
abc1234 report: final aggregation | V:85% | Q:78% | S:82%
def5678 Merge branch spatial-scoring
ghi9abc Merge branch quant-scoring
jkl2def Merge branch verbal-scoring
mno5ghi checkpoint: Q50 answered
```

---

## Memory Recovery

### Single-Agent Recovery (Current)

```bash
# On context reset, reload from git history
CHECKPOINT=$(git log --oneline | grep "checkpoint: Q" | head -1)
LAST_Q=$(echo $CHECKPOINT | grep -oP 'Q\d+' | tail -1)

# Resume from Q_N+1
echo "Resuming from Q$(($LAST_Q + 1))"
```

### Multi-Branch Recovery (Future)

```bash
# Check branch completion status
for branch in verbal-scoring quant-scoring spatial-scoring; do
  status=$(git log $branch --oneline | head -1 | grep -c "scored")
  if [ $status -eq 1 ]; then
    echo "✓ $branch: Complete"
  else
    echo "⏳ $branch: In progress"
    # Resume in-progress branch
    git worktree remove .agent/worktrees/$branch
    git worktree add .agent/worktrees/$branch $branch
    git -C .agent/worktrees/$branch checkout $branch
  fi
done
```

---

## Conflict-Free Design

### Why No Conflicts?

Parallel branches **never conflict** because:

1. **Separate Files:** Each branch modifies different files
   - verbal-branch: `verbal-score.json`
   - quant-branch: `quant-score.json`
   - spatial-branch: `spatial-score.json`

2. **Sequential Main:** Main branch only adds Q1-Q50 sequentially (no parallel writes)

3. **Read-Only in Branches:** Domain branches only READ test-results.json (don't write)

### Merge Strategy

Simple 3-way merge (no conflict resolution needed):

```bash
# All merges are "add new files" (never conflicts)
git merge verbal-scoring
#   verbal-score.json: added ✓

git merge quant-scoring
#   quant-score.json: added ✓

git merge spatial-scoring
#   spatial-score.json: added ✓
```

---

## Implementation Checklist

### Step 1: Create Worktrees (On-Demand)

```bash
# Create worktree for parallel task
create_worktree() {
  local branch=$1
  local path=".agent/worktrees/$branch"
  
  if [ ! -d "$path" ]; then
    git worktree add "$path" "$branch"
    echo "✓ Created worktree: $path"
  fi
}

create_worktree "verbal-scoring"
create_worktree "quant-scoring"
create_worktree "spatial-scoring"
```

### Step 2: Execute in Parallel

```bash
# Execute 4 tasks in parallel
cd .agent/worktrees/main && execute_main_task &
cd .agent/worktrees/verbal-branch && execute_verbal_scoring &
cd .agent/worktrees/quant-branch && execute_quant_scoring &
cd .agent/worktrees/spatial-branch && execute_spatial_scoring &

# Wait for all to complete
wait

echo "✓ All parallel tasks complete"
```

### Step 3: Merge Results

```bash
# Return to main
cd /path/to/repo

# Merge domain branches
git merge verbal-scoring --no-edit
git merge quant-scoring --no-edit
git merge spatial-scoring --no-edit

# Generate aggregate report
aggregate_scores() {
  python << EOF
import json
verbal = json.load(open('.agent/worktrees/verbal-branch/verbal-score.json'))
quant = json.load(open('.agent/worktrees/quant-branch/quant-score.json'))
spatial = json.load(open('.agent/worktrees/spatial-branch/spatial-score.json'))
overall = (verbal['avg'] + quant['avg'] + spatial['avg']) / 3
print(f"Final Score: {overall:.1f}%")
EOF
}

aggregate_scores

# Commit final result
git commit -am "report: final aggregation [$(date -u +%Y-%m-%d)]"
```

### Step 4: Cleanup

```bash
# Remove worktrees after use
cleanup_worktrees() {
  git worktree remove .agent/worktrees/verbal-branch
  git worktree remove .agent/worktrees/quant-branch
  git worktree remove .agent/worktrees/spatial-branch
  echo "✓ Worktrees cleaned up"
}

cleanup_worktrees
```

---

## Performance Characteristics

### Single-Branch (Current)

```
Timeline: Q1 → Q2 → Q3 → ... → Q50
Duration: 10-15 minutes (sequential)
Memory: 1 git branch, ~50 commits
```

### Multi-Branch (Future)

```
Timeline:
  Main:    Q1 → Q2 → ... → Q50       (10-15 min)
  Verbal:  V1 → V2 → ... → V10       (3-5 min parallel)
  Quant:   Q1 → Q2 → ... → Q10       (3-5 min parallel)
  Spatial: S1 → S2 → ... → S10       (3-5 min parallel)
  Report:  Aggregate results         (1 min)

Total: Max(15 min, 5 min, 5 min, 5 min, 1 min) = 15 min (Q presentation is bottleneck)

Parallelization gains: Not in total time (presenter blocks), but enables:
  - Concurrent scoring if using multiple agents
  - Reduced latency if tasks could run in parallel
  - A/B testing (2 branches with different models)
```

---

## Future Extensions

### Parallel Domain Scoring with Separate Agents

```
Agent: Question Presenter  (Main)
Agent: Verbal Scorer       (Verbal Branch)
Agent: Quant Scorer        (Quant Branch)
Agent: Spatial Scorer      (Spatial Branch)
Agent: Report Generator    (Report Branch)

All run in parallel, coordinated by Supervisor
```

### A/B Testing Variant

```
Main Branch: Control (current harness v1.0.0)
  └─ Test all 50 Qs with v1.0.0

Test Branch: Variant (new harness v1.1.0)
  └─ Test all 50 Qs with v1.1.0 (same questions, different logic)

Compare: v1.0.0 score vs v1.1.0 score on same test
```

---

## References

- **CLAUDE.md §25** — Branch-based memory section (will be added)
- **supervisor.md** — Orchestration context (.agent/orchestration/)
- **HE-TIER3-PLAN.md** — Branch-based memory specification

---

**Status:** Foundation Ready (Tier 3 P1-9)  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
