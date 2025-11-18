# GPU nightly batch

Shows how to describe a CronJob style workload via `ai-workloads.batchTasks`
and land it on GPU nodes using the shared infra profile catalogue.

## What runs

- A single CronJob named `<release>-ai-workloads-gpu-nightly`.
- `infraProfile: gpu-small` requests one NVIDIA GPU plus the matching
  tolerations/node selectors from the platform profile.
- The pod mounts an existing PVC called `shared-blob-pvc` at `/mnt/blob` so the
  batch script can read inputs and write outputs.
- A cron schedule of `0 1 * * *` executes the job daily at 01:00 cluster time.

## Try it

```bash
cd examples/gpu-nightly-batch
helm dependency build
helm template gpu-nightly-batch .
```

You should see the CronJob plus the ConfigMap-derived pod spec in the rendered
manifests.

## Values to notice

- The example keeps `apps: []` to emphasise that you can ship *only* batch
  tasks when needed.
- `env` illustrates how to pass runtime paths to your container.
- `activeDeadlineSeconds` and `backoffLimit` ensure the CronJob fails fast if it
  gets stuck, which protects GPU capacity.
- Replace `persistentVolumeClaim.claimName` with your own PVC name before
  running this in a real namespace.
