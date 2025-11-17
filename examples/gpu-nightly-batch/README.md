# gpu-nightly-batch

GPU nightly batch job using **ai-workloads** `batchTasks` and a blob-backed PVC.

This example assumes a `shared-blob-pvc` PVC already exists in the target
namespace (for example created using your platform's PVC blueprint).

## Behaviour

When you install this chart:

- The `ai-workloads` subchart creates a **CronJob** called
  `<release>-ai-workloads-gpu-nightly`.
- The CronJob runs **once per day at 01:00** (`schedule: "0 1 * * *"`).
- The pod:
  - Uses the **`gpu-small` infraProfile**, which requests a single NVIDIA GPU.
  - Mounts the PVC `shared-blob-pvc` at `/mnt/blob`.
  - Reads `.pt` tensors from `/mnt/blob/incoming`.
  - Writes normalised tensors to `/mnt/blob/processed`.

The container image is built from the supplied `Dockerfile` and contains a small
`run_batch.py` script that uses `torch` on GPU when available.

### Important variables

In `values.yaml` under `ai-workloads.batchTasks[0]`:

- `infraProfile: gpu-small`  
  Tells the ai-workloads chart to pull the **GPU resource profile** from the
  central `infraProfiles` map (defined in the platform chart). This profile
  typically sets `requests/limits` for `nvidia.com/gpu`, CPU, memory,
  nodeSelector and tolerations to land on GPU nodes.

- `volumeMounts` / `volumes`  
  Mount the pre-existing `shared-blob-pvc` into the container:
  - `mountPath: /mnt/blob`
  - `INPUT_DIR` and `OUTPUT_DIR` environment variables are pointed into
    subdirectories under this mount.

- `activeDeadlineSeconds: 3600`  
  Kills any run that takes more than an hour. This protects you from stuck
  jobs that burn GPU time forever.

- `schedule: "0 1 * * *"`  
  Standard cron expression in **cluster local time**. This controls how often
  the CronJob runs; all retry behaviour is handled by Kubernetes `backoffLimit`
  and `activeDeadlineSeconds`.

You generally **do not need** to touch any ai-workloads internals for this
example; you only describe the batch in `ai-workloads.batchTasks`.
