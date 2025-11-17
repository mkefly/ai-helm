# ai-workloads Helm Chart

`ai-workloads` is a **central Helm chart** for deploying AI workloads:

- Long-lived services via `apps[]` (Deployments + optional Service + HPA)
- Batch workloads via `batchTasks[]` (Jobs and CronJobs)
- Optional inline or external settings ConfigMaps (`settings`, `settingsConfigMapName`, `settingsMountPath`)
- Optional Istio `VirtualService` routing and Entra ID (AAD) authorization

Label conventions:

- `app.kubernetes.io/name` – chart fullname (release + chart)
- `app.kubernetes.io/instance` – Helm release name (standard)
- `app.kubernetes.io/part-of` – logical app/task name (per entry in `apps[]` / `batchTasks[]`)

KEDA, ingress and PVC creation are intentionally kept outside this chart
and shown in examples only.
