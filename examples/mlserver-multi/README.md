# mlserver-multi

Example showing **multiple MLServer deployments** in a single `ai-workloads`
release, all using `kind: mlserver` but with different settings and infra
profiles.

## Scenario

You want to expose two independent MLServer models:

- `mlserver-a` – small, low-latency model on `cpu-small` profile.
- `mlserver-b` – heavier model on `cpu-medium` profile with separate HPA
  settings.

Each MLServer instance has its own:

- Deployment
- Service
- ConfigMap with `settings.json`

All of them are described under a single `ai-workloads.apps` array.

## Behaviour

When you install this chart:

- `ai-workloads` creates two Deployments:
  - `<release>-ai-workloads-mlserver-a`
  - `<release>-ai-workloads-mlserver-b`
- Each Deployment has:
  - Its own `Service` (port 8000) and settings ConfigMap.
  - A writable `/models` directory backed by an auto-injected `emptyDir`
    volume (unless you override it with a PVC).
  - Its own HPA with independent metrics.
- If you enable Istio in a higher-level chart, the VirtualService will expose
  both apps under different paths (by default `/mlserver-a` and `/mlserver-b`
  if `basePath` is `/`).

### Key values

Under `ai-workloads.apps` in `values.yaml`:

- `kind: mlserver`
  Turns on MLServer-specific defaults in ai-workloads:
  - Default Service on port 8000 if not present.
  - `MLSERVER_HTTP_PORT` set to the service port.
  - Default liveness/readiness probes targeting the health endpoints.
  - `settingsMountPath` set to `/etc/settings` when `settings` is provided.
  - Auto-mounted `emptyDir` volume at `/models` for writable storage.

- `settings` (per app)  
  Each app has its own JSON block rendered into a `<app-name>-settings`
  ConfigMap, mounted as `/etc/settings/settings.json` in that app only.

- `infraProfile`  
  Separates resource sizing:
  - `mlserver-a` can stay cheap on `cpu-small`.
  - `mlserver-b` can use `cpu-medium` (more CPU/memory).

- `hpa`
  Optional per-app HPA; you can enable/disable independently and use different
  metrics. For example in this sample:
  - `mlserver-a` scales between 1 and 5 replicas (60% CPU target).
  - `mlserver-b` scales between 1 and 10 replicas (70% CPU target).

This pattern generalises well to any number of MLServer-backed models. You just
add more `kind: mlserver` entries to the `apps` array.
