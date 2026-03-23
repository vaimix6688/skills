# Root Cause Analysis (RCA) Template

Use this template for post-mortem documentation of P0 and P1 incidents.

---

## Incident Summary

| Field | Value |
|---|---|
| **Incident ID** | <!-- e.g., INC-2026-042 --> |
| **Severity** | <!-- P0 / P1 --> |
| **Date** | <!-- YYYY-MM-DD --> |
| **Duration** | <!-- e.g., 2 hours 15 minutes --> |
| **Affected services** | <!-- e.g., event-chain-service, qr-verify-service --> |
| **Reported by** | <!-- Name or monitoring system --> |
| **Resolved by** | <!-- Name(s) --> |

## Description

<!-- One paragraph summary of what happened, from the user's perspective. -->

## Timeline

All times in UTC.

| Time | Event |
|---|---|
| `HH:MM` | <!-- Issue first detected (monitoring alert / user report) --> |
| `HH:MM` | <!-- On-call engineer acknowledged --> |
| `HH:MM` | <!-- Initial investigation began --> |
| `HH:MM` | <!-- Root cause identified --> |
| `HH:MM` | <!-- Fix deployed to staging --> |
| `HH:MM` | <!-- Fix deployed to production --> |
| `HH:MM` | <!-- Incident resolved, monitoring confirmed --> |

## Root Cause

<!-- Describe the technical root cause in detail. What exactly went wrong and why? -->
<!-- Be specific: "The event-chain-service did not handle null tenant_id in batch processing, causing a panic" -->
<!-- not vague: "There was a bug in the code" -->

### Contributing Factors

<!-- What conditions or decisions contributed to this incident? -->

- <!-- e.g., Missing input validation for edge case -->
- <!-- e.g., Integration test did not cover this scenario -->
- <!-- e.g., Configuration drift between staging and production -->

## Impact

### User Impact

| Metric | Value |
|---|---|
| **Users affected** | <!-- e.g., ~500 users across 12 tenants --> |
| **Duration of impact** | <!-- e.g., 2 hours --> |
| **Functionality affected** | <!-- e.g., QR verification returned 500 errors --> |

### Data Impact

| Metric | Value |
|---|---|
| **Data loss** | <!-- Yes/No. If yes, describe extent --> |
| **Data corruption** | <!-- Yes/No. If yes, describe extent --> |
| **Data recovered** | <!-- Yes/No. If yes, describe how --> |

### Business Impact

<!-- Financial impact, SLA violations, customer complaints, regulatory implications. -->

## Resolution

### Immediate Fix

<!-- What was done to stop the bleeding? -->

```
<!-- Include relevant commands, code changes, or configuration changes -->
```

### Permanent Fix

<!-- What longer-term fix was applied or is planned? -->
<!-- Link to the PR(s) that contain the fix. -->

## Action Items

| # | Action | Owner | Deadline | Status |
|---|---|---|---|---|
| 1 | <!-- e.g., Add regression test for null tenant_id in batch processing --> | <!-- Name --> | <!-- YYYY-MM-DD --> | <!-- Open / In Progress / Done --> |
| 2 | <!-- e.g., Add monitoring alert for panic rate > 0 --> | <!-- Name --> | <!-- YYYY-MM-DD --> | <!-- Open / In Progress / Done --> |
| 3 | <!-- e.g., Audit all batch processing endpoints for similar issue --> | <!-- Name --> | <!-- YYYY-MM-DD --> | <!-- Open / In Progress / Done --> |
| 4 | <!-- e.g., Update staging environment to match production config --> | <!-- Name --> | <!-- YYYY-MM-DD --> | <!-- Open / In Progress / Done --> |

## Lessons Learned

### What went well

- <!-- e.g., Monitoring detected the issue within 2 minutes -->
- <!-- e.g., On-call response was fast -->
- <!-- e.g., Rollback procedure worked smoothly -->

### What went poorly

- <!-- e.g., Root cause took 45 minutes to identify due to insufficient logging -->
- <!-- e.g., No runbook existed for this failure mode -->
- <!-- e.g., Staging did not reproduce the issue initially -->

### Where we got lucky

- <!-- e.g., The bug only affected new declarations; existing data was unharmed -->
- <!-- e.g., Low traffic period reduced the number of affected users -->

## Prevention

<!-- What systemic changes will prevent this class of incident from recurring? -->

- <!-- e.g., Add tenant_id null-check middleware to all batch endpoints -->
- <!-- e.g., Add integration test that exercises batch processing with missing fields -->
- <!-- e.g., Implement configuration parity checks between staging and production -->

---

**RCA Author:** <!-- Name -->
**Review Date:** <!-- YYYY-MM-DD -->
**Reviewed By:** <!-- Team lead name -->
