# fastapi-hpa

FastAPI deployment using the `ai-workloads` chart, with a simple CPU-based HPA.

This example shows:

- A `kind: fastapi` service deployed as a Deployment.
- A ClusterIP service on port 8000.
- A HorizontalPodAutoscaler that keeps average CPU around 60% across 2–8 pods.

## Behaviour

When you install this chart:

- `ai-workloads` creates a `Deployment` named
  `<release>-ai-workloads-fastapi-app`.
- The Deployment:
  - Runs `uvicorn main:app` on port `8000`.
  - Exposes `/health` and `/ping` endpoints.
- A `Service` selects pods by `app.kubernetes.io/name: fastapi-app` and
  exposes port `8000` to the namespace.
- An HPA scales the deployment between 2 and 8 replicas based on CPU.

There is no Ingress/VirtualService; you typically combine this with your own
ingress or call it from inside the cluster.

### Key variables

Under `ai-workloads.apps[0]` in `values.yaml`:

- `infraProfile: cpu-small`  
  Reuses the central CPU resource profile. If your platform team updates the
  profile, all services using it inherit the change.

- `replicas: 2`  
  Baseline replica count. The HPA scales on top of this.

- `hpa.metrics`  
  Explicit CPU metric for `autoscaling/v2`:
  - `averageUtilization: 60` means target average CPU usage per pod of ~60%.

- `env`  
  Example of passing standard environment variables (here only `LOG_LEVEL`).

`settings`, `volumeMounts` and `volumes` are left empty to keep the example
focused on compute and autoscaling.
