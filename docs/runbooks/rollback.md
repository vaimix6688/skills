# Runbook: Emergency Rollback

**Scope:** Emergency rollback of a failed or problematic Project production deployment.

**Owner:** Platform Engineering (on-call engineer)

**Estimated duration:** 10-30 minutes (rollback only), longer if database migration rollback is needed

**Last updated:** 2026-03-22

---

## When to Use This Runbook

Trigger an emergency rollback when ANY of the following conditions are met after a deployment:

- Error rate (5xx) > 1% of requests for 5 minutes
- Latency P99 > 500ms for 5 minutes
- Kafka consumer lag > 10,000 messages for 10 minutes
- Any critical business flow broken (C/O generation, batch creation, ZK verification)
- Healthcheck failures for any service lasting > 3 minutes
- External sync failure rate > 5% for 10 minutes

---

## Step 1: Identify the Issue

**Responsible:** On-call engineer

**Time target:** 5 minutes

### 1.1 Confirm the problem is real

```bash
# Check error rate
curl -s "http://grafana:3000/api/datasources/proxy/1/api/v1/query?query=rate(http_requests_total{status=~'5..'}[5m])"

# Check pod status
kubectl get pods -n myproject-production --sort-by='.status.startTime'

# Check recent logs for errors
kubectl logs -n myproject-production -l app.kubernetes.io/part-of=myproject --tail=100 --since=10m | grep -i error
```

### 1.2 Determine scope

- Which service(s) are affected?
- Is it all traffic or specific endpoints?
- Did it start exactly after deployment?
- Are there external factors (External API down, database issues)?

Record findings:
```
Issue: <description>
Affected service(s): <list>
Started at: <timestamp>
Correlated with deployment: yes / no / unclear
```

---

## Step 2: Decision — Rollback vs Hotfix

**Responsible:** On-call engineer + engineering lead

**Time target:** 5 minutes for decision

Use this decision tree:

```
Is the issue causing data loss or corruption?
├── YES → ROLLBACK IMMEDIATELY (go to Step 3)
└── NO
    ├── Is the issue affecting >10% of users?
    │   ├── YES → ROLLBACK (go to Step 3)
    │   └── NO
    │       ├── Is a fix obvious and < 15 minutes to deploy?
    │       │   ├── YES → HOTFIX (see Hotfix Path below)
    │       │   └── NO → ROLLBACK (go to Step 3)
    │       └──
    └──
```

### Hotfix Path (only if criteria above are met)

1. Create hotfix branch from the release tag
2. Apply minimal fix
3. Run tests
4. Deploy using the standard [Deploy Release](./deploy-release.md) runbook (abbreviated)
5. If hotfix does not resolve the issue within 15 minutes, proceed to rollback

**Rule of thumb:** When in doubt, rollback. A rollback is always safer than a rushed hotfix.

---

## Step 3: ArgoCD Rollback

**Responsible:** On-call engineer

**Time target:** 5 minutes

### 3.1 Identify the previous healthy revision

```bash
# List deployment history
argocd app history myproject-<service>

# Example output:
# ID  DATE                 REVISION
# 5   2026-03-22 10:00:00  abc1234 (current — broken)
# 4   2026-03-20 14:00:00  def5678 (previous — known good)
# 3   2026-03-18 09:00:00  ghi9012
```

### 3.2 Execute rollback

```bash
# Rollback to previous revision
argocd app rollback myproject-<service> <revision-id>

# Example:
argocd app rollback myproject-core 4

# If multiple services need rollback:
argocd app rollback myproject-core 4
argocd app rollback myproject-ingestion 4
argocd app rollback myproject-compliance 4
# ... repeat for each affected service
```

### 3.3 Alternative: Helm rollback (if ArgoCD is unavailable)

```bash
# List Helm release history
helm history myproject-<service> -n myproject-production

# Rollback to previous revision
helm rollback myproject-<service> <revision> -n myproject-production --wait --timeout 10m
```

### 3.4 Alternative: Manual image tag revert

If both ArgoCD and Helm are problematic:

```bash
# Set image directly
kubectl set image deployment/myproject-<service> \
  myproject-<service>=myproject/<service>:vX.Y.(Z-1) \
  -n myproject-production

# Watch rollout
kubectl rollout status deployment/myproject-<service> -n myproject-production
```

---

## Step 4: Database Migration Rollback (If Applicable)

**Responsible:** On-call engineer + database owner

> **WARNING:** Database rollbacks can cause data loss. Only proceed if the migration is the root cause of the issue. Consult the engineering lead before executing.

### 4.1 Determine if migration rollback is needed

```
Did the failed release include database migrations?
├── NO → Skip this step entirely (go to Step 5)
└── YES
    ├── Is the old code compatible with the new schema?
    │   ├── YES → DO NOT rollback the migration. The code rollback (Step 3) is sufficient.
    │   └── NO → Proceed with migration rollback (4.2)
    └──
```

### 4.2 Assess data loss risk

Before rolling back a migration, assess:

- **Additive migrations** (new columns, new tables): Safe to keep — old code ignores them
- **Column renames/drops**: Rolling back will restore old columns but NEW data written to renamed/dropped columns WILL BE LOST
- **Data transformations**: Rolling back may not perfectly reverse the transformation — DATA LOSS POSSIBLE

| Migration Type | Rollback Risk | Recommendation |
|---|---|---|
| Add column | None | Do NOT rollback — leave the column |
| Add table | None | Do NOT rollback — leave the table |
| Add index | None | Do NOT rollback — leave the index |
| Rename column | **HIGH** — data in new column name lost | Rollback only if critical |
| Drop column | **CRITICAL** — data is gone | Cannot rollback — restore from backup |
| Data transformation | **HIGH** — may not be reversible | Assess case by case |

### 4.3 Execute migration rollback

```bash
# Check current migration version
npm run migration:status -- --env=production

# Rollback last migration
npm run migration:rollback -- --env=production

# Rollback multiple migrations (specify count)
npm run migration:rollback -- --env=production --step=N

# Verify migration state
npm run migration:status -- --env=production
```

### 4.4 If data loss occurred

1. Stop all writes to the affected table(s)
2. Assess the extent of data loss
3. If needed, restore from the most recent backup:
   ```bash
   # List available backups
   aws rds describe-db-cluster-snapshots --db-cluster-identifier myproject-production

   # Point-in-time restore (creates new instance)
   aws rds restore-db-cluster-to-point-in-time \
     --source-db-cluster-identifier myproject-production \
     --db-cluster-identifier myproject-production-restore \
     --restore-to-time <timestamp-before-migration>
   ```
4. Manually migrate needed data from restored instance to production
5. This is a major incident — escalate immediately

---

## Step 5: Verify System Recovered

**Responsible:** On-call engineer

**Time target:** 15 minutes of monitoring

### 5.1 Immediate verification

```bash
# Check all pods are running
kubectl get pods -n myproject-production

# Check healthchecks
for svc in core ingestion ai crypto compliance; do
  echo "myproject-$svc: $(curl -s -o /dev/null -w '%{http_code}' http://myproject-$svc.myproject-production.svc/health)"
done

# Check ArgoCD status
argocd app list | grep myproject
```

### 5.2 Verify metrics returned to normal

| Metric | Target | Dashboard |
|---|---|---|
| Error rate | < 0.5% | Grafana: `myproject-error-rate` |
| P99 latency | < 200ms | Grafana: `myproject-latency` |
| Kafka consumer lag | Decreasing | Grafana: `kafka-consumer-lag` |
| External sync | > 95% success | Admin portal |

### 5.3 Run smoke tests

```bash
npm run test:smoke -- --env=production
```

### 5.4 Confirm with stakeholders

- [ ] Verify the original issue is resolved
- [ ] Check Slack `#myproject-support` — any new user complaints?
- [ ] Notify `#myproject-releases` that rollback is complete

---

## Step 6: Post-Mortem

**Responsible:** On-call engineer (initiate), engineering lead (own)

**Time target:** Start within 24 hours, complete within 72 hours

### 6.1 Announce the incident

Post to `#myproject-incidents`:

```
INCIDENT RESOLVED: <title>
- Duration: <start time> to <end time>
- Impact: <description of user impact>
- Root cause: <preliminary — to be confirmed in post-mortem>
- Resolution: Rollback to vX.Y.(Z-1)
- Post-mortem scheduled: <date/time>
```

### 6.2 Create post-mortem document

Use the [Root Cause Analysis template](../templates/root-cause-analysis.md) and fill in:

1. **Timeline:** Detailed timeline of events from deployment to resolution
2. **Impact:** Number of users affected, duration of impact, business impact
3. **Root cause:** What went wrong and why it was not caught before production
4. **Contributing factors:** Process gaps, missing tests, monitoring gaps
5. **Action items:** Specific, assigned, time-bound improvements
   - What test would have caught this?
   - What monitoring would have alerted sooner?
   - What process change would prevent this?

### 6.3 Prevent reoccurrence

Before re-attempting the failed deployment:

- [ ] Root cause is identified and fixed
- [ ] New tests are added to cover the failure case
- [ ] Fix is verified in staging environment
- [ ] Post-mortem action items are tracked in the issue tracker

---

## Appendix: Communication Template

### During Rollback

```
@channel ALERT: Rolling back deployment vX.Y.Z.
Reason: <brief description>
Impact: <what users may experience>
ETA: <estimated time to recovery>
Point of contact: <on-call engineer>
```

### After Rollback Complete

```
@channel RESOLVED: Rollback of vX.Y.Z complete.
System restored to vX.Y.(Z-1).
Duration of impact: <X minutes>
Post-mortem will be scheduled.
```

## Appendix: Emergency Contacts

| Role | Name | Contact |
|---|---|---|
| Platform Lead | Chi Phuong | Slack: @phuong, Phone: xxx |
| Backend Lead | TBD | Slack: @tbd |
| On-call engineer | Rotation | PagerDuty: myproject-oncall |
| Database admin | TBD | Slack: @tbd |
