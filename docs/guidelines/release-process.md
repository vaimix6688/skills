# Release Process

This document defines how Project services are versioned, released, and deployed.

## Semantic Versioning

All Project repositories follow [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

| Component | When to Increment | Example |
|---|---|---|
| **MAJOR** | Breaking API changes, incompatible schema changes | `1.0.0` to `2.0.0` |
| **MINOR** | New features, backward-compatible additions | `1.0.0` to `1.1.0` |
| **PATCH** | Bug fixes, security patches, no feature changes | `1.0.0` to `1.0.1` |

### Pre-release Versions

For release candidates and beta builds:

```
1.2.0-rc.1
1.2.0-beta.3
```

## Release Cadence

| Release Type | Cadence | Trigger |
|---|---|---|
| **Minor** | Weekly (every Tuesday) | Scheduled |
| **Patch** | As needed | Bug fix or security issue |
| **Major** | Quarterly or as needed | Breaking changes |
| **Hotfix** | Immediate | P0 incident |

## Tag Convention

Git tags follow the format `v<MAJOR>.<MINOR>.<PATCH>`:

```
v1.0.0
v1.1.0
v1.1.1
v2.0.0-rc.1
```

Tags are created from the `main` branch only. Tags are immutable — never delete or move a tag.

## Release Checklist

Before creating a release, verify every item on this checklist:

### Pre-Release

- [ ] All tests pass on `main` (unit, integration, E2E).
- [ ] Code coverage has not decreased.
- [ ] Security scan shows no new critical/high vulnerabilities.
- [ ] `CHANGELOG.md` is updated with all changes since the last release.
- [ ] Version number is bumped in relevant files:
  - Go: version constant or build tag
  - Rust: `Cargo.toml` version field
  - TypeScript: `package.json` version field
  - Python: `pyproject.toml` or `__version__` variable
- [ ] Database migrations are tested (up and down).
- [ ] API documentation is updated (if API changes).
- [ ] Feature flags are configured for gradual rollout (if applicable).
- [ ] Dependent services are compatible with the new version.

### Release

- [ ] Tag is created and pushed:
  ```bash
  git tag -a v1.2.0 -m "Release v1.2.0"
  git push origin v1.2.0
  ```
- [ ] GitHub Release is created with release notes from CHANGELOG.
- [ ] Container images are built and pushed to registry.
- [ ] Deployment pipeline is triggered.

### Post-Release

- [ ] Staging deployment verified.
- [ ] Production canary deployment verified.
- [ ] Full production rollout completed.
- [ ] Monitoring dashboards checked (error rates, latency, resource usage).
- [ ] Team notified of successful release.

## Release Workflow

### Step 1: Prepare the Release

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Update CHANGELOG.md (see changelog-template.md)
# Update version numbers
# Commit the version bump
git add -A
git commit -m "chore(release): bump version to v1.2.0"
git push origin main
```

### Step 2: Create the Tag

```bash
git tag -a v1.2.0 -m "Release v1.2.0: Add Business Event validation, fix QR cache"
git push origin v1.2.0
```

### Step 3: Create GitHub Release

Use the GitHub CLI or web UI:

```bash
gh release create v1.2.0 \
  --title "v1.2.0" \
  --notes-file CHANGELOG_EXCERPT.md
```

### Step 4: Deploy

The CI/CD pipeline automatically builds and deploys when a new tag is pushed. The deployment follows this order:

1. Build container images.
2. Run smoke tests against the built images.
3. Deploy to staging.
4. Run E2E tests against staging.
5. Deploy canary to production (10% traffic).
6. Monitor for 15 minutes.
7. Full production rollout.

## Database Migration Strategy

Database migrations require special care during releases:

### Forward Migration

1. Migrations must be **backward compatible** — the old application version must still work with the new schema.
2. Deploy the migration first, then deploy the new application version.
3. Use additive changes: add columns (with defaults), add tables, add indexes.
4. Never rename or drop columns in the same release as the code change.

### Two-Phase Schema Changes

For breaking schema changes, use a two-release approach:

**Release N:**
- Add the new column/table.
- Update code to write to both old and new locations.
- Deploy.

**Release N+1:**
- Remove writes to the old location.
- Drop the old column/table.
- Deploy.

### Migration Testing

- Every migration must have a corresponding rollback (down migration).
- Test migrations against a copy of production data before release.
- Migration scripts live in `myproject-infra/db-migrations/`.

## Rollback Procedure

If a release causes issues in production:

### Immediate Rollback (Application)

```bash
# Revert the merge commit on main
git revert <commit-sha>
git push origin main

# Or deploy the previous tag directly
kubectl set image deployment/<service> <container>=<registry>/<image>:v1.1.0
```

### Database Rollback

```bash
# Run the down migration
migrate -path ./migrations -database "$DATABASE_URL" down 1
```

Only roll back the database if the migration itself caused the issue. If only the application code is problematic, revert the code and leave the (backward-compatible) migration in place.

### Rollback Decision Tree

1. Is the issue P0? **Rollback immediately**, then investigate.
2. Is the issue P1? Attempt a forward fix within 2 hours. If not resolved, rollback.
3. Is the issue P2/P3? Fix forward in the next patch release.

## Feature Flags

Use feature flags for gradual rollout of significant changes:

### When to Use Feature Flags

- New user-facing features.
- Changes to critical business logic (C/O calculations, event chain processing).
- Risky infrastructure changes.
- Features that depend on external service availability.

### Implementation

Feature flags are managed via environment variables or a configuration service:

```go
if featureFlags.IsEnabled("epcis-v2-validation", tenantID) {
    return validateBusiness Eventv2(event)
}
return validateBusiness Eventv1(event)
```

### Lifecycle

1. **Create** the flag before the feature is merged.
2. **Enable** for internal testing, then canary users, then all users.
3. **Remove** the flag and dead code within 2 sprints after full rollout.

Do not accumulate feature flags. Stale flags add complexity and must be cleaned up.

## Canary Deployment

Critical services use canary deployment:

1. Deploy the new version to a small subset of instances (10% of traffic).
2. Monitor key metrics for 15 minutes:
   - Error rate (must not increase by more than 0.1%).
   - P99 latency (must not increase by more than 20%).
   - CPU and memory usage (must not spike).
3. If metrics are healthy, proceed to full rollout.
4. If metrics degrade, automatically roll back the canary.

### Services Requiring Canary Deployment

| Service | Reason |
|---|---|
| `event-chain-service` | Core data pipeline |
| `qr-verify-service` | High traffic, user-facing |
| `co-engine` | Regulatory compliance |
| `nbc-gateway` | External integration |

## Changelog

Every release must have an updated `CHANGELOG.md` following the format in [changelog-template.md](../templates/changelog-template.md). The changelog is the source of truth for release notes.

## Notifications

After a successful production deployment:

- Post in the `#releases` channel with version, key changes, and any known issues.
- Update the internal status page if the release affects external-facing services.
- Notify affected partner teams if API behavior changes.
