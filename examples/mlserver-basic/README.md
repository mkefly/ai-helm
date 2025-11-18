# MLServer basic deployment

Ships a single MLServer model with ephemeral `/models` storage so you can see
how the `kind: mlserver` defaults behave before wiring in a persistent volume.

## Highlights

- `kind: mlserver` auto-injects the command, probes, service on port `8000` and
  sets `MLSERVER_HTTP_PORT` for you.
- `settings` is rendered to a ConfigMap and mounted at `/etc/settings`; the
  sample JSON loads one SKLearn model.
- An `emptyDir` volume makes `/models` writable without provisioning a PVC.
- CPU autoscaling keeps between 1 and 5 replicas with a 60% utilisation target.

## Try it locally

```bash
cd examples/mlserver-basic
helm dependency build
helm template mlserver-basic .
```

This runs entirely against the local copy of the `ai-workloads` chart.

## Customising storage later

Swap the `volumes` block for a PVC once you are ready to persist the model:

```yaml
volumeMounts:
  - name: model-storage
    mountPath: /models
volumes:
  - name: model-storage
    persistentVolumeClaim:
      claimName: my-models-pvc
```

Everything else in `values.yaml` can remain the same; MLServer will immediately
start reading from the PVC instead of the ephemeral directory.
