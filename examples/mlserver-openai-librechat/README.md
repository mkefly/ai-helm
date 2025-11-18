# LibreChat behind OAuth + MLServer runtime

End-to-end showcase that wires together an MLServer runtime implementing the
OpenAI API, the LibreChat backend and an oauth2-proxy front door that enforces
Azure AD sign-in. It also demonstrates how the `ai-workloads` chart renders
RequestAuthentication and AuthorizationPolicy resources when AAD + Istio are
enabled.

## Components

1. **runtime-openai** – `kind: mlserver` app exposing port 8000.
2. **librechat-backend** – `kind: librechat` service that calls runtime-openai
   via its ClusterIP and remains internal (`skipVirtualService: true`).
3. **librechat** – `kind: oauth2-proxy` instance that fronts LibreChat and is
   exposed through the shared Istio VirtualService.

## Platform bits enabled here

- `aad` + `requestAuth` describe the Azure AD tenant and audience used by Istio
  to validate JWTs.
- `aadPolicies` defines a namespace-wide policy plus an override that keeps
  `/docs` on `runtime-openai` publicly reachable.
- The shared ServiceAccount carries a Workload Identity annotation so oauth2-proxy
  can request tokens from Azure.
- The Istio block declares the external host, gateway and `/apps` base path.

## Try it

```bash
cd examples/mlserver-openai-librechat
helm dependency build
helm template mlserver-openai-librechat .
```

Rendering will output Deployments, Services, HPAs, AuthorizationPolicies and a
VirtualService whose routes map `/apps/<app-name>` to each workload.

## Customise for your tenant

Before installing this chart for real, change the placeholder IDs in
`values.yaml`:

- `aad.tenantId` and `aad.apiAudience` to match your Entra ID tenant + app.
- `serviceAccount.annotations.azure.workload.identity/client-id` so the pods can
  request tokens with your workload identity.
- Secret names referenced by `OPENAI_API_KEY` and the oauth2-proxy env vars.
- All URLs under the oauth2-proxy args so that redirects and upstreams point to
  your domains.
