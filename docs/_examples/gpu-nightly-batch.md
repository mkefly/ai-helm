# GPU nightly batch

Nightly GPU CronJob reading from and writing to a blob-mounted PVC. Render with:

```bash
cd examples/gpu-nightly-batch
helm dependency build
helm template gpu-nightly-batch .
```

## Values

--8<-- "examples/gpu-nightly-batch/values.yaml"

## Dockerfile

--8<-- "examples/gpu-nightly-batch/Dockerfile"

## run_batch.py

--8<-- "examples/gpu-nightly-batch/run_batch.py"
