# Web Search & MCP Integration (P1-6)

**Feature:** P1-6 (Web Search / MCP)  
**Tier:** Tier 3 (Nice-to-Have)  
**Purpose:** Enable real-time knowledge access for dynamic test content  
**Status:** Optional Integration Ready

---

## Overview

Web search and MCP (Model Context Protocol) integration provide access to external knowledge sources, enabling:
- Dynamic test questions that reference current data
- Real-time information retrieval during test execution
- Access to domain-specific APIs and knowledge bases

**Note:** For CCAT (static test with fixed 50 questions), this feature is low priority. Enable if test content becomes dynamic.

---

## Web Search Integration

### When to Use

Web search is useful if:
- Test questions reference current events or data
- Answer keys depend on real-time information
- Need to validate user answers against current sources

### Example: Dynamic Question

```markdown
**Q23 (Current Events Domain):**
"As of April 2026, who is the current President of the United States?"

Answer: Joe Biden (current as of April 2026)

To validate user answer:
1. Enable web search
2. Search: "President of United States 2026"
3. Compare user answer to search result
4. Score: Correct if matches current office holder
```

### Implementation

```python
# Optional: Add to test harness
def validate_answer_with_search(question_id, user_answer):
    """Validate answer using web search if needed"""
    
    if should_use_web_search(question_id):
        # Search for current information
        search_query = extract_search_query(question_id)
        search_results = web_search(search_query)
        
        # Compare user answer to search results
        validation = compare_answer(user_answer, search_results)
        return validation
    else:
        # Use static answer key (default)
        return compare_to_answer_key(user_answer)
```

---

## MCP (Model Context Protocol) Integration

### What is MCP?

MCP enables Claude to interact with external tools and data sources via a standardized protocol:
- Connect to databases
- Call APIs
- Access domain-specific knowledge
- Real-time data retrieval

### Example Integrations

#### Integration 1: News API

```json
{
  "mcp_server": "news-api",
  "endpoint": "https://newsapi.org/v2/",
  "use_case": "Validate answers about recent events",
  "example_call": {
    "query": "What happened in tech industry last week?",
    "domain": "technology",
    "date_range": "last_7_days"
  }
}
```

#### Integration 2: Wikipedia API

```json
{
  "mcp_server": "wikipedia",
  "endpoint": "https://en.wikipedia.org/api/",
  "use_case": "Validate factual answers",
  "example_call": {
    "query": "Capital of France",
    "extract": "first_paragraph"
  }
}
```

#### Integration 3: Custom Domain API

```json
{
  "mcp_server": "custom-domain-knowledge",
  "endpoint": "https://api.example.com/knowledge/",
  "use_case": "Domain-specific fact validation",
  "authentication": "API_KEY",
  "example_call": {
    "topic": "quantum_computing",
    "detail_level": "expert"
  }
}
```

---

## Configuration

### Enable Web Search

In CLAUDE.md or `.agent/config.json`:

```json
{
  "features": {
    "web_search_enabled": false,
    "web_search_timeout": 5,
    "web_search_max_results": 5
  }
}
```

To enable:
```bash
# Option 1: Set environment variable
export CCAT_WEB_SEARCH_ENABLED=true

# Option 2: Update config file
jq '.features.web_search_enabled = true' .agent/config.json > temp && mv temp .agent/config.json

# Option 3: CLI flag
./run-test.sh --enable-web-search
```

### Configure MCP Servers

File: `.agent/mcp-servers.json`

```json
{
  "servers": [
    {
      "name": "web-search",
      "enabled": false,
      "type": "built-in",
      "timeout": 5
    },
    {
      "name": "wikipedia",
      "enabled": false,
      "type": "external",
      "endpoint": "https://en.wikipedia.org/api/",
      "timeout": 3
    },
    {
      "name": "news-api",
      "enabled": false,
      "type": "external",
      "endpoint": "https://newsapi.org/v2/",
      "api_key": "${NEWS_API_KEY}",
      "timeout": 5
    }
  ]
}
```

---

## Implementation Notes

### Current Status (CCAT)

For the standard CCAT test:
- ❌ Web search NOT needed (static test)
- ❌ MCP NOT needed (fixed question set)
- ✅ Static answer key sufficient
- ✅ No real-time data required

### When to Enable

Enable Web Search / MCP if:
1. Test content becomes dynamic
2. Questions reference current events
3. Answer keys depend on real-time data
4. Need specialized domain knowledge
5. Implementing adaptive testing

### Performance Considerations

| Factor | Impact | Mitigation |
|--------|--------|-----------|
| Network latency | +5-10 sec per search | Cache results |
| API rate limits | Fewer searches available | Batch queries |
| API failures | Test cannot continue | Graceful fallback |
| Privacy concerns | Data shared with APIs | Use private APIs only |

### Privacy & Security

- **API Keys:** Store in environment variables, not code
- **User Data:** Don't send PII to external APIs
- **Caching:** Cache search results to reduce API calls
- **Audit:** Log all external API calls for compliance

---

## Integration Checklist (If Enabling)

- [ ] Enable web_search_enabled flag
- [ ] Add API keys to environment
- [ ] Configure MCP servers
- [ ] Add timeout handling (5-10 sec max)
- [ ] Implement fallback to static answers
- [ ] Add caching layer for results
- [ ] Log all external API calls
- [ ] Test with sample dynamic questions
- [ ] Update audit logs
- [ ] Document in CLAUDE.md

---

## Example: Conditional Web Search

```python
# Pseudo-code for conditional web search
def score_answer(question_id, user_answer):
    question = get_question(question_id)
    
    # Check if question needs web search
    if question.get("requires_current_data"):
        # Search for current information
        search_query = question.get("search_query")
        results = web_search(search_query, timeout=5)
        
        # Validate against search results
        if answer_matches_search_results(user_answer, results):
            return {"correct": True, "source": "web_search"}
        else:
            return {"correct": False, "source": "web_search"}
    else:
        # Use static answer key (default)
        expected = get_answer_key(question_id)
        if user_answer == expected:
            return {"correct": True, "source": "static_key"}
        else:
            return {"correct": False, "source": "static_key"}
```

---

## References

- **Web Search Tool:** Built-in Claude capability
- **MCP Protocol:** https://modelcontextprotocol.io/
- **Integration Examples:** `.agent/mcp-servers.json`
- **Status:** Ready for optional deployment

---

**Status:** Optional Integration (Tier 3 P1-6)  
**Priority:** Low (CCAT uses static test)  
**Last Updated:** 2026-04-05  
**Version:** v1.0.0
