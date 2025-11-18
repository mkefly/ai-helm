# FastAPI HPA scenario

Deploys a FastAPI microservice with the `ai-workloads` chart and proves that
kind-specific defaults plus an explicit CPU HPA are enough to keep the service
healthy under load.

## What this example covers

- A `kind: fastapi` Deployment exposed on port `8000`.
- Automatic ConfigMap + volume mount generated from the `settings` block.
- CPU-based autoscaling from 2 to 8 replicas.
- A simple example of templated environment variables (if you want to inject
  release-specific values later).

## Try it locally

```bash
cd examples/fastapi-hpa
helm dependency build
helm template fastapi-hpa .
```

The dependency build step uses the local `../../chart` directory, so you do not
need to pull `ai-workloads` from an OCI registry when iterating.

## Key values

`values.yaml` contains a single entry under `ai-workloads.apps`:

- `infraProfile: cpu-small` keeps the pod requests/limits consistent with the
  shared platform profile.
- `settings` renders into `/etc/settings/settings.json` which FastAPI can read
  at start-up.
- `env` shows how to pass static env vars; they are processed via `tpl`, so you
  can switch them to templated strings when you need release-specific values.
- `hpa.metrics` demonstrates a fully specified `autoscaling/v2` metric; the
  chart intentionally does not guess sensible defaults for you.

There is intentionally no Ingress/VirtualService in this example to keep the
focus on compute and autoscaling. Combine it with your platform's ingress layer
when you want to expose it.
