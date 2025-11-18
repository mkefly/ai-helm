# ai-workloads Helm Chart

This repo contains:

- `chart/` – the **ai-workloads** Helm chart.
- `examples/` – product charts using `ai-workloads` as a dependency.
- `docs/` – MkDocs documentation.

## Running examples

Each example is a small, self-contained Helm chart using `ai-workloads` as a
local dependency (`file://../../chart`). Render any of them with:

```bash
cd examples/<name>
helm dependency build
helm template <name> .
```

Available scenarios:

- `examples/fastapi-hpa`
- `examples/mlserver-basic`
- `examples/mlserver-multi`
- `examples/gpu-nightly-batch`
- `examples/mlserver-openai-librechat`

## Continuous testing

The `.gitlab-ci.yml` file defines a GitLab pipeline that lints the base chart
and renders every example chart. Each example is treated as a regression test,
so changes to `chart/` or the examples themselves must still template cleanly.

