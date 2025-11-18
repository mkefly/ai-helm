# MLServer + LibreChat

MLServer runtime.openai endpoint plus LibreChat behind oauth2-proxy, all using
`ai-workloads`. Render with:

```bash
cd examples/mlserver-openai-librechat
helm dependency build
helm template mlserver-openai-librechat .
```

## Values

--8<-- "examples/mlserver-openai-librechat/values.yaml"
