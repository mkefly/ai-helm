# Multiple MLServer models

Demonstrates how a single release of `ai-workloads` can host several MLServer
Deployments, each with its own infra profile, settings and autoscaler.

## Scenario

- `mlserver-a` represents a latency-sensitive fraud model.
- `mlserver-b` handles heavier recommendation traffic on a beefier profile and a
  custom service port.

Both workloads share the same chart release yet remain completely independent in
terms of HPAs, settings ConfigMaps and routing.

## Try it

```bash
cd examples/mlserver-multi
helm dependency build
helm template mlserver-multi .
```

After rendering you will see two Deployments, two Services and two HPAs.

## Notes on the values

- `infraProfile` is used to give each model its own CPU/memory sizing.
- `settings` blocks render distinct ConfigMaps named
  `<release>-ai-workloads-<app>-settings`.
- `mlserver-b` overrides the service port to `9000` and explicitly exports
  `MLSERVER_HTTP_PORT` to emphasise how you can deviate from the defaults.
- HPAs are defined per entry, so you can tweak scaling behaviour independently.
