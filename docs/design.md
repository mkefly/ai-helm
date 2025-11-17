# Design Rationale

Key decisions:

- Single chart for all AI workloads (`apps[]` + `batchTasks[]`).
- No KEDA, ingress, or PVC creation inside the chart.
- Per-app and per-task `volumeMounts` / `volumes` for blob / files.
- Optional inline or external settings ConfigMaps:
  - `settings` (inline JSON, ConfigMap auto-created)
  - `settingsConfigMapName` (reuse an existing ConfigMap)
  - `settingsMountPath` (override mount path)
- Compatible with MLServer, FastAPI, vLLM, runtime.openai and custom workloads.
- Optional Istio `VirtualService` routing based on `istio.*` values, with
  regex-based path handling so subpaths like `/v1/...` or `/docs` are preserved.
- Optional Entra ID (AAD) integration for Istio with `aad`, `requestAuth`, `aadPolicies`.
  This chart assumes **Azure AD / Entra ID** tokens and only inspects Azure-specific
  claims such as `aud`, `groups` and `azp`.
- DRY pod spec via a single `ai-workloads.podSpec` helper used by Deployments, Jobs and CronJobs.
- Label semantics aligned with common tooling:
  - `app.kubernetes.io/instance` = Helm release name
  - `app.kubernetes.io/name` = chart fullname (release + chart)
  - `app.kubernetes.io/part-of` = logical app/task name (per entry)

## Security notes

### allowSameNamespaceInternal

`aadPolicies[].allowSameNamespaceInternal: true` adds a broad rule that trusts
any workload in the namespace. This is convenient for early experiments but
should be used with care in production. Prefer:

- namespace-wide policies with explicit `allowedGroups` / `allowedClientIds`, or
- app-specific policies using label selectors or explicit `selector` blocks.

### RequestAuthentication namespaces

`RequestAuthentication` resources are created:

- in the release namespace, and
- in every namespace referenced by `aadPolicies[].namespace` (or the release
  namespace if omitted).

This ensures JWT validation is available wherever `AuthorizationPolicy` is
applied.
