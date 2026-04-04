# Harness Versioning & A/B Testing (P0-8)

**Feature:** P0-8 (Harness Versioning)  
**Tier:** Tier 3 (Nice-to-Have)  
**Purpose:** Enable version tracking and A/B testing of harness improvements  
**Status:** Operational

---

## Versioning Scheme

Format: `MAJOR.MINOR.PATCH`

### MAJOR Version Changes

**Increment when:** Breaking changes to agent interface or test structure

Examples:
- Switch to different LLM model (Claude 3 → Claude 4)
- Change question order or count
- Alter scoring formula
- Restructure test domains

Current: `v1.0.0` (Tier 1 + Tier 2)

### MINOR Version Changes

**Increment when:** New features added (new Tier features, new capabilities)

Examples:
- Add new domain (verbal, quant, spatial)
- Add secondary validator (QA Auditor)
- Add orchestration logic
- Add pattern auditing

Timeline:
```
v1.0.0 (Tier 1 + Tier 2) — 2026-04-05
v1.1.0 (+ Tier 3a) — 2026-04-12 (estimated)
v1.2.0 (+ Tier 3b) — 2026-04-19 (estimated)
v1.3.0 (+ Tier 3c) — 2026-04-26 (estimated, if all Tier 3 implemented)
```

### PATCH Version Changes

**Increment when:** Bug fixes, optimizations, documentation updates

Examples:
- Fix scoring calculation error
- Optimize checkpoint compression
- Update README documentation
- Improve error messages

Format: `v1.0.1`, `v1.0.2`, etc.

---

## Version Metadata

### Version Information File

File: `.agent/harness-version.json`

```json
{
  "version": "1.0.0",
  "release_date": "2026-04-05T00:00:00.000Z",
  "tier": "Tier 1 + Tier 2",
  "maturity": "70% (21/30 features)",
  "status": "production",
  "components": {
    "core": {
      "version": "1.0.0",
      "status": "stable"
    },
    "auditor": {
      "version": "1.0.0",
      "status": "new (Tier 3)"
    },
    "pattern_audit": {
      "version": "1.0.0",
      "status": "new (Tier 3)"
    }
  },
  "git_commit": "ca8c414...",
  "python_version": "3.8+",
  "node_version": "14+",
  "claude_model": "Claude 3.5 (latest)"
}
```

### Version in CLAUDE.md

```
Last Updated: 2026-04-05 (v1.0.0)
Harness Version: v1.0.0
Maturity: 70% (21/30 features)
```

---

## Performance Tracking per Version

### Metrics Schema

File: `.session/version-metrics-[VERSION].json`

```json
{
  "version": "1.0.0",
  "test_date": "2026-04-05",
  "metrics": {
    "test_runs": 5,
    "avg_completion_time": "14:23",
    "avg_score": 82.5,
    "min_score": 78,
    "max_score": 88,
    "context_resets": 0,
    "escalations": 0,
    "errors": 0,
    "reliability": 100
  },
  "domain_breakdown": {
    "verbal_avg": 85.0,
    "quantitative_avg": 78.0,
    "spatial_avg": 82.5
  }
}
```

### Aggregated Metrics

File: `.session/version-comparison.json`

```json
{
  "versions_compared": ["1.0.0", "1.1.0"],
  "comparison_date": "2026-04-20",
  "results": [
    {
      "version": "1.0.0",
      "test_runs": 10,
      "avg_time": "14:32",
      "avg_score": 81.2,
      "reliability": 100
    },
    {
      "version": "1.1.0",
      "test_runs": 10,
      "avg_time": "14:15",
      "avg_score": 83.5,
      "reliability": 100
    }
  ],
  "verdict": "v1.1.0 faster (17 sec) and higher avg score (+2.3%); recommend rollout"
}
```

---

## A/B Testing Framework

### Setup A/B Test

```bash
#!/bin/bash
# a-b-test.sh — Compare two harness versions

VERSION_A="v1.0.0"
VERSION_B="v1.1.0"
RUNS_PER_VERSION=5

echo "A/B Testing: ${VERSION_A} vs ${VERSION_B}"
echo "Runs per version: ${RUNS_PER_VERSION}"

# Test Version A
echo "Testing ${VERSION_A}..."
for i in $(seq 1 $RUNS_PER_VERSION); do
  git checkout v1.0.0
  time run_test | tee ".session/test-${VERSION_A}-run-${i}.json"
done

# Test Version B
echo "Testing ${VERSION_B}..."
for i in $(seq 1 $RUNS_PER_VERSION); do
  git checkout v1.1.0
  time run_test | tee ".session/test-${VERSION_B}-run-${i}.json"
done

# Compare
compare_versions "$VERSION_A" "$VERSION_B" > .session/version-comparison.json
echo "✓ A/B test complete: $(cat .session/version-comparison.json | jq '.verdict')"
```

### Decision Matrix

```
Metric           | v1.0.0  | v1.1.0  | Better? | Weight
Time (avg)       | 14:32   | 14:15   | v1.1.0  | 20%
Score (avg)      | 81.2%   | 83.5%   | v1.1.0  | 50%
Reliability      | 100%    | 100%    | Tie     | 20%
Context Resets   | 0       | 0       | Tie     | 10%

Weighted Score:
v1.0.0 = (0 + 0 + 20 + 10) = 30
v1.1.0 = (20 + 50 + 20 + 10) = 100

Recommendation: Rollout v1.1.0 (100 > 30)
```

---

## Release Checklist

Before releasing a new version:

- [ ] All tests pass (`.github/workflows/test.yml`)
- [ ] No critical bugs (escalation_count == 0)
- [ ] Performance benchmarks acceptable
- [ ] Documentation updated (CLAUDE.md version tag)
- [ ] CHANGELOG.md updated with release notes
- [ ] Git tag created (`git tag -a v1.1.0`)
- [ ] Version file updated (`.agent/harness-version.json`)
- [ ] A/B test against previous version (if MINOR/MAJOR change)
- [ ] Release notes published

---

## Version Rollback

If issues detected in new version:

```bash
# Identify issue
git log --oneline | head -5
# Determine last stable version
git checkout v1.0.0

# Create hotfix branch
git checkout -b hotfix/critical-issue

# Fix issue
# ... make fix ...
git commit -m "fix: critical issue in v1.1.0"

# Merge to main
git checkout main
git merge hotfix/critical-issue

# Create patch version
git tag -a v1.0.1
git push origin v1.0.1

echo "✓ Rollback to v1.0.1 complete"
```

---

## References

- **CLAUDE.md** — Version tag (Last Updated line)
- **CHANGELOG.md** — Release history
- **HE-COMPLETE-ROADMAP.md** — Feature timeline
- **A/B Testing Examples** — In `.session/version-comparison.json`

---

**Status:** Operational (Tier 3 P0-8)  
**Last Updated:** 2026-04-05  
**Current Version:** v1.0.0
