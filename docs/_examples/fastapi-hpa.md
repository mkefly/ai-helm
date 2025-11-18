# FastAPI with HPA

Deploys a FastAPI service that leans on the `fastapi` kind defaults in
`ai-workloads` and adds an explicit CPU HPA. Render it the same way the CI
pipeline does:

```bash
cd examples/fastapi-hpa
helm dependency build
helm template fastapi-hpa .
```

## Values

--8<-- "examples/fastapi-hpa/values.yaml"

## Dockerfile

--8<-- "examples/fastapi-hpa/Dockerfile"

## main.py

--8<-- "examples/fastapi-hpa/main.py"
