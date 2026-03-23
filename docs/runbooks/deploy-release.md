# Runbook: Deploy Release

**Scope:** Production deployment of a new Project release across all services.

**Owner:** Platform Engineering (Chi Phuong / on-call engineer)

**Estimated duration:** 45-90 minutes (depending on number of services)

**Last updated:** 2026-03-22

---

## Rollback Trigger Criteria

Before starting, understand when to abort and rollback. If ANY of the following conditions are met after deployment, initiate rollback immediately (see [Rollback Runbook](./rollback.md)):

| Metric | Threshold | Monitoring Source |
|---|---|---|
| Error rate (5xx) | > 1% of requests for 5 minutes | Grafana: `myproject-error-rate` dashboard |
| Latency P99 | > 500ms for 5 minutes | Grafana: `myproject-latency` dashboard |
| Kafka consumer lag | > 10,000 messages for 10 minutes | Grafana: `kafka-consumer-lag` panel |
| External sync failures | > 5% of sync attempts for 10 minutes | Admin portal: External Sync Health |
| Healthcheck failures | Any service unhealthy for 3 minutes | ArgoCD / Kubernetes |
| Critical business flow broken | Any (C/O generation, batch creation, ZK verification) | Smoke tests / user reports |

---

## Pre-Deployment Checklist

**Responsible:** Release engineer (the person performing the deployment)

- [ ] **1.1** All CI tests pass on the release branch/tag
  ```
  # Verify in GitHub Actions or CI dashboard
  gh run list --branch release/vX.Y.Z --limit 5
  ```
- [ ] **1.2** Changelog is updated in `CHANGELOG.md` for each affected service
- [ ] **1.3** Git tag is created and pushed
  ```bash
  git tag -a vX.Y.Z -m "Release vX.Y.Z: <summary>"
  git push origin vX.Y.Z
  ```
- [ ] **1.4** Database migrations reviewed and approved (if any)
  - Check: Are migrations backward-compatible? Can the old code run with the new schema?
  - If NOT backward-compatible: this requires a multi-phase deployment (migrate first, deploy second)
- [ ] **1.5** Feature flags reviewed — any flags that should be toggled with this release?
- [ ] **1.6** Notify the team in Slack `#myproject-releases` channel
  ```
  Deploying vX.Y.Z to production. Starting at <time>. ETA: <duration>.
  Changes: <link to changelog>
  ```
- [ ] **1.7** Confirm no other deployments are in progress
- [ ] **1.8** Confirm current production is healthy (no active incidents)

---

## Step 1: Build Docker Images

**Responsible:** CI/CD pipeline (triggered automatically) or release engineer (manual)

Build Docker images for each service included in the release.

```bash
# Services to build (only those with changes in this release):
# myproject-core, myproject-ingestion, myproject-ai, myproject-crypto,
# myproject-compliance, myproject-frontend (web-app, gov-portal, admin-portal, bots)

# Automated (preferred): CI builds on tag push
# Manual (fallback):
docker build -t myproject/<service>:vX.Y.Z -f <service>/Dockerfile .
```

**Verification:**
- [ ] All images build successfully
- [ ] Image tags match the release version `vX.Y.Z`
- [ ] Image size is reasonable (no unexpected bloat)

---

## Step 2: Push to Container Registry

**Responsible:** CI/CD pipeline or release engineer

```bash
# Push all built images to the container registry
docker push myproject/<service>:vX.Y.Z

# Verify images are available
aws ecr describe-images --repository-name myproject/<service> --image-ids imageTag=vX.Y.Z
```

**Verification:**
- [ ] All images are present in the registry with correct tags
- [ ] Image digests are recorded for audit trail

---

## Step 3: Update Helm Values

**Responsible:** Release engineer

Update the image tag in Helm values for each service.

```bash
# In myproject-infra repository
cd myproject-infra/helm/values/production/

# Update image tags for each service
# Example for myproject-core:
# Edit values-myproject-core.yaml:
#   image:
#     tag: "vX.Y.Z"    # was: "vX.Y.(Z-1)"
```

**Important:** Update one service at a time if doing a rolling deployment. Update all at once only if services must be deployed together (breaking API changes).

```bash
# Commit and push
git add .
git commit -m "release: update image tags to vX.Y.Z"
git push origin main
```

**Verification:**
- [ ] All affected service values files are updated
- [ ] Changes are committed and pushed to the infra repository

---

## Step 4: ArgoCD Sync (Deploy)

**Responsible:** Release engineer

### Option A: ArgoCD Auto-Sync (preferred)

If ArgoCD auto-sync is enabled, it will detect the Helm values change and begin syncing automatically.

```bash
# Monitor sync status
argocd app list | grep myproject
argocd app get myproject-<service> --refresh
```

### Option B: Manual ArgoCD Sync

```bash
# Sync specific application
argocd app sync myproject-<service>

# Or sync all Project apps
argocd app sync -l app.kubernetes.io/part-of=myproject
```

### Option C: Helm Upgrade (fallback if ArgoCD unavailable)

```bash
helm upgrade myproject-<service> ./charts/myproject-<service> \
  -f values/production/values-myproject-<service>.yaml \
  --namespace myproject-production \
  --wait \
  --timeout 10m
```

**Verification:**
- [ ] ArgoCD shows all applications as "Synced" and "Healthy"
- [ ] No pods in CrashLoopBackOff or Error state
- [ ] Rolling update completed — old pods terminated, new pods running

---

## Step 5: Verify Healthchecks

**Responsible:** Release engineer

```bash
# Check pod status
kubectl get pods -n myproject-production -l app.kubernetes.io/version=vX.Y.Z

# Check readiness and liveness probes
kubectl describe pod <pod-name> -n myproject-production | grep -A5 "Conditions"

# Check service endpoints
kubectl get endpoints -n myproject-production
```

Verify each service health endpoint responds:

| Service | Health Endpoint | Expected |
|---|---|---|
| myproject-core | `GET /health` | `200 {"status": "ok"}` |
| myproject-ingestion | `GET /health` | `200 {"status": "ok"}` |
| myproject-ai | `GET /health` | `200 {"status": "ok"}` |
| myproject-crypto | `GET /health` | `200 {"status": "ok"}` |
| myproject-compliance | `GET /health` | `200 {"status": "ok"}` |
| web-app | `GET /` | `200` |
| gov-portal | `GET /` | `200` |
| admin-portal | `GET /` | `200` |

**Decision point:** If any healthcheck fails after 3 minutes, proceed to [Rollback](./rollback.md).

---

## Step 6: Run Smoke Tests

**Responsible:** Release engineer

Run the automated smoke test suite against production.

```bash
# Run smoke tests
cd myproject-core
npm run test:smoke -- --env=production

# Or via CI
gh workflow run smoke-tests.yml -f environment=production -f version=vX.Y.Z
```

### Critical Smoke Tests (must all pass)

| Test | Description | Max Duration |
|---|---|---|
| `smoke:auth` | Login flow for all user types | 30s |
| `smoke:batch-create` | Create a test batch with lineage | 60s |
| `smoke:co-calculate` | Run C/O RVC calculation | 30s |
| `smoke:zk-verify` | Generate and verify a ZK proof | 30s |
| `smoke:nbc-sync` | Trigger External sync (test endpoint) | 60s |
| `smoke:bot-parse` | Send test message to Zalo/Telegram bot | 30s |
| `smoke:gov-search` | Search batch in gov-portal API | 30s |

**Decision point:** If any critical smoke test fails, proceed to [Rollback](./rollback.md).

---

## Step 7: Monitor for 30 Minutes

**Responsible:** Release engineer (must remain available)

After smoke tests pass, actively monitor the system for 30 minutes.

### Monitoring Checklist (check every 5 minutes)

- [ ] **Error rate** remains below 1% — Grafana: `myproject-error-rate`
- [ ] **Latency P99** remains below 500ms — Grafana: `myproject-latency`
- [ ] **Kafka consumer lag** stable or decreasing — Grafana: `kafka-consumer-lag`
- [ ] **External sync success rate** above 95% — Admin portal
- [ ] **No new error patterns** in logs — Grafana Loki: `{namespace="myproject-production"} |= "error"`
- [ ] **No user complaints** in Slack `#myproject-support`

### What to Watch For

| Signal | Normal | Warning | Critical (rollback) |
|---|---|---|---|
| Error rate | < 0.5% | 0.5-1% | > 1% for 5 min |
| P99 latency | < 200ms | 200-500ms | > 500ms for 5 min |
| Kafka lag | < 1,000 | 1,000-10,000 | > 10,000 for 10 min |
| Pod restarts | 0 | 1-2 | 3+ in 10 min |

**Decision point:** If any metric enters the "Critical" column, proceed to [Rollback](./rollback.md).

---

## Step 8: Announce Completion

**Responsible:** Release engineer

Post deployment completion to Slack `#myproject-releases`:

```
Deployment vX.Y.Z completed successfully.
- Start time: <time>
- End time: <time>
- Duration: <duration>
- Services deployed: <list>
- Monitoring window: passed (30 min, no issues)
- Changelog: <link>
```

### Post-Deployment Tasks

- [ ] Update release notes on GitHub
- [ ] Close related JIRA/Linear tickets
- [ ] Toggle any feature flags that were gated on this release
- [ ] Notify affected tenants if there are user-facing changes
- [ ] Update internal documentation if APIs changed

---

## Appendix: Deployment Order

When deploying multiple services, follow this order to respect dependencies:

1. **myproject-crypto** (no dependencies)
2. **myproject-core** (depends on crypto)
3. **myproject-compliance** (depends on core)
4. **myproject-ingestion** (depends on core)
5. **myproject-ai** (depends on core, ingestion)
6. **myproject-frontend** (all frontend apps — depends on core API)

If all services are backward-compatible, they can be deployed in parallel.

## Appendix: Emergency Contacts

| Role | Name | Contact |
|---|---|---|
| Platform Lead | Chi Phuong | Slack: @phuong, Phone: xxx |
| Backend Lead | TBD | Slack: @tbd |
| On-call engineer | Rotation | PagerDuty: myproject-oncall |
| External API support | External helpdesk | Email: support@nbc.gov.vn |
