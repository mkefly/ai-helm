# Configuration

This chart exposes two main arrays: `apps[]` and `batchTasks[]`.

## `apps[]` – Long-lived services

```yaml
apps:
  - name: app-a
    kind: fastapi
    infraProfile: cpu-small
    replicas: 1
    image:
      repository: ghcr.io/acme/app-a
      tag: v1.0.0
      pullPolicy: IfNotPresent
    service:
      enabled: true
      type: ClusterIP
      ports:
        - name: http
          port: 8080
          protocol: TCP
    settings: |-
      {
        "name": "app-a",
        "runtime": "mlserver"
      }
    settingsConfigMapName: ""
    settingsMountPath: "/etc/settings"
    command: []
    args: []
    env: []
    envFrom: []
    labels: {}
    annotations: {}
    podAnnotations: {}
    resources: {}
    volumeMounts: []
    volumes: []
    hpa:
      enabled: false
      minReplicas: 1
      maxReplicas: 5
      targetCPUUtilizationPercentage: 60
```

If `settingsConfigMapName` is empty and `settings` is provided, a ConfigMap
named `<release>-ai-workloads-<app-name>-settings` is created and mounted
at `settingsMountPath`.

If `settingsConfigMapName` is set, that ConfigMap is mounted at
`settingsMountPath` and no new ConfigMap is created.

## `batchTasks[]` – Jobs and CronJobs

```yaml
batchTasks:
  - name: gpu-daily-task
    kind: batch-gpu
    infraProfile: gpu-small
    image:
      repository: ghcr.io/acme/gpu-daily-task
      tag: v1.0.0
      pullPolicy: IfNotPresent
    settings: |-
      {
        "task_name": "daily-gpu-job"
      }
    settingsConfigMapName: ""
    settingsMountPath: "/etc/settings"
    command: ["python"]
    args:
      - "/app/run_daily_task.py"
      - "--config"
      - "/etc/settings/settings.json"
    env: []
    envFrom: []
    labels: {}
    annotations: {}
    podAnnotations: {}
    resources: {}
    volumeMounts: []
    volumes: []
    activeDeadlineSeconds: 900
    schedule: "0 2 * * *"
```

If `schedule` is empty, a **Job** is created.  
If `schedule` is set (cron string), a **CronJob** is created.
