# Program: [Research Direction Name]

## Goal

What are you trying to improve or explore? Be specific about the desired outcome but leave the "how" open for experimentation.

Example: "Reduce API response latency for the /events endpoint from ~200ms to under 50ms"

## Current State

What's the baseline? Include current metrics if available.

- Current metric value: [e.g., 200ms p95 latency]
- Known bottlenecks: [e.g., N+1 queries, no caching]
- Constraints: [e.g., must remain backward-compatible, no new infrastructure]

## Exploration Areas

Suggest directions to explore (agent can deviate if better ideas emerge):

1. [e.g., Query optimization — batch queries, add indexes]
2. [e.g., Caching layer — Redis, in-memory, HTTP cache headers]
3. [e.g., Data model changes — denormalization, materialized views]
4. [e.g., Algorithm improvements — pagination strategy, lazy loading]

## Boundaries

What should NOT be changed:
- [e.g., Public API contract must stay the same]
- [e.g., Don't add new infrastructure dependencies]
- [e.g., Don't modify shared libraries]

## Metric

How to measure success:
```bash
# Command that outputs a single number (lower/higher is better)
# Examples:
# npm run bench -- --grep "events" | grep "ops/sec" | awk '{print $3}'
# curl -s -o /dev/null -w "%{time_total}" http://localhost:3000/api/events
# wc -l dist/bundle.js
```

Direction: lower_is_better | higher_is_better

## Time Budget

- Per iteration: 300 seconds (5 minutes)
- Total experiments: ~20-50 (overnight run)

---

*This file is the "steering wheel" — you set the direction, the agent drives.*
*Inspired by Karpathy's autoresearch: humans program direction, agents execute experiments.*
