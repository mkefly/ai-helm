# mlserver-basic

Simple **MLServer** deployment using the `ai-workloads` chart.

This example shows:

- How `kind: mlserver` automatically:
  - Adds a `Service` on port 8000 (if you don't define one).
  - Sets `MLSERVER_HTTP_PORT` based on the service port.
  - Adds basic liveness/readiness probes.
  - Defaults the command to `mlserver start --settings /etc/settings/settings.json`.
- How MLServer apps automatically receive writable `/models` storage using an
  `emptyDir` volume when you haven't defined your own `/models` mount.
- How to attach a simple CPU-based HPA.

We assume you want MLServer to read/write under `/models` but you don't yet
have a PVC provisioned. `kind: mlserver` therefore injects an `emptyDir`
volumeMount for `/models` (only when you haven't already defined one) so the
container receives a writable filesystem scoped to the Pod's lifecycle. If you
already have a PVC, see the **Customising the storage** section below.

## Behaviour

When you install this chart:

- `ai-workloads` creates a `Deployment` named
  `<release>-ai-workloads-mlserver-model` with:
  - 1 replica by default.
  - Container image `ghcr.io/acme/mlserver-basic-model:v1.0.0`.
- Volume mount from an `emptyDir` volume at `/models` (added automatically by
  the mlserver kind defaults when you haven't set up `/models` yourself).
- A `ClusterIP` service exposes MLServer on port `8000`.
- A HorizontalPodAutoscaler (HPA) scales between 1 and 5 replicas based on
  average CPU utilisation (60%).

Incoming traffic is **cluster-internal only**; there is no Ingress/VirtualService
in this example.

### Key variables

Under `ai-workloads.apps[0]` in `values.yaml`:

- `kind: mlserver`  
  Activates MLServer kind-specific defaults in the ai-workloads chart:
  - Service default on port 8000 if missing.
  - Default probes.
  - Default command/args and settings mount when `settings` is provided.

- `settings`  
  JSON payload rendered into a ConfigMap called
  `<release>-ai-workloads-mlserver-model-settings` and mounted at
  `/etc/settings/settings.json`. MLServer reads this at startup.

- `volumes`
  `kind: mlserver` injects a `model-storage` volume backed by `emptyDir` when
  you don't define one. Override this block if you need a PVC instead (see
  below).

### Customising the storage

`emptyDir` is convenient for experimentation but is erased when the Pod is
rescheduled. Override the injected `model-storage` volume to use a
`persistentVolumeClaim` and keep model artifacts across Pod restarts (the
auto-generated `volumeMounts` entry already points to `/models` unless you've
defined one yourself):

```yaml
volumes:
  - name: model-storage
    persistentVolumeClaim:
      claimName: models-blob-pvc
```

The chart does not create the PVC for you; it must exist ahead of time.

If you prefer to manage the mount completely, add your own `/models`
`volumeMounts` entry plus a matching volume definition. The mlserver helper
detects that `/models` is already handled and skips injecting the default
`emptyDir`.

- `hpa.metrics`  
  Explicit autoscaling configuration for the `autoscaling/v2` API:
  - type: `Resource`
  - resource name: `cpu`
  - target type: `Utilization`
  - `averageUtilization: 60`

The ai-workloads chart **does not** infer HPA settings; when `hpa.enabled=true`
you must provide at least one metric, or the HPA will be skipped.
