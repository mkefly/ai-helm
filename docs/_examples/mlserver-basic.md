# MLServer basic

A single MLServer deployment with a writable `/models` path. Render it with:

```bash
cd examples/mlserver-basic
helm dependency build
helm template mlserver-basic .
```

## Values

--8<-- "examples/mlserver-basic/values.yaml"
