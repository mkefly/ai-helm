# Getting Started

## 1. Package and publish the chart

From `chart/`:

```bash
cd chart
helm package .
helm push ai-workloads-0.9.1.tgz oci://ghcr.io/acme/charts
```

## 2. Add as a dependency in your product chart

```yaml
apiVersion: v2
name: my-product
version: 0.1.0

dependencies:
  - name: ai-workloads
    version: 0.9.1
    repository: oci://ghcr.io/acme/charts
```

## 3. Define workloads in your values.yaml

Use:

- `ai-workloads.apps` for services
- `ai-workloads.batchTasks` for Jobs / CronJobs

See the examples section for full, ready-to-run values.
