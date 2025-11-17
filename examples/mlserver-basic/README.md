# mlserver-basic

Simple **MLServer** deployment using the `ai-workloads` chart.

This example shows:

- How `kind: mlserver` automatically:
  - Adds a `Service` on port 8000 (if you don't define one).
  - Sets `MLSERVER_HTTP_PORT` based on the service port.
  - Adds basic liveness/readiness probes.
  - Defaults the command to `mlserver start --settings /etc/settings/settings.json`.
- How to mount a PVC with model files.
- How to attach a simple CPU-based HPA.

We assume:

- A `models-blob-pvc` PVC already exists in the target namespace.
- Your model files live under `/models/my-model` inside that PVC.

## Behaviour

When you install this chart:

- `ai-workloads` creates a `Deployment` named
  `<release>-ai-workloads-mlserver-model` with:
  - 1 replica by default.
  - Container image `ghcr.io/acme/mlserver-basic-model:v1.0.0`.
  - Volume mount from `models-blob-pvc` at `/models`.
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

- `volumeMounts` / `volumes`  
  Map the `models-blob-pvc` PVC to `/models`, and the model config refers to
  `/models/my-model` in the `settings` block.

- `hpa.metrics`  
  Explicit autoscaling configuration for the `autoscaling/v2` API:
  - type: `Resource`
  - resource name: `cpu`
  - target type: `Utilization`
  - `averageUtilization: 60`

The ai-workloads chart **does not** infer HPA settings; when `hpa.enabled=true`
you must provide at least one metric, or the HPA will be skipped.
