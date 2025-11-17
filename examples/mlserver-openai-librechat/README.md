# mlserver-openai-librechat

Composite example showing **three** workloads wired together via the
`ai-workloads` chart:

1. `runtime-openai` – an MLServer-based runtime that exposes an OpenAI-compatible API.
2. `librechat-backend` – LibreChat backend, configured to call `runtime-openai`.
3. `librechat` – an `oauth2-proxy` front end that:
   - Enforces Azure AD / Entra ID login.
   - Proxies authenticated users to LibreChat backend.

Istio and AAD are enabled **only** in this example to demonstrate how the
`istio`, `aad`, `requestAuth` and `aadPolicies` values behave.

## Behaviour

When you install this chart:

- `ai-workloads` creates three Deployments and three Services, one per app.
- An Istio `VirtualService` (in the ai-workloads chart) routes:
  - `https://ai.example.com/apps/runtime-openai/...` → `runtime-openai` service.
  - `https://ai.example.com/apps/librechat/...` → `librechat` (oauth2-proxy).
- A namespace-wide `AuthorizationPolicy` (`ns-all`) requires valid JWTs for
  **all** inbound traffic to namespace `ai`.
- An additional `AuthorizationPolicy` (`runtime-openai`) allows unauthenticated
  access **only** to `/docs` on `runtime-openai`.

### Key ai-workloads values

All ai-workloads-related values are nested under the `ai-workloads:` key in
`values.yaml` because this chart depends on ai-workloads as a subchart.

#### AAD & Istio

- `aad.tenantId` and `aad.apiAudience`  
  Used to build the issuer and JWKS URIs for Istio `RequestAuthentication` and
  to restrict accepted `aud` claims.

- `requestAuth.enabled: true`  
  Tells ai-workloads to render `RequestAuthentication` resources for:
  - The release namespace.
  - Any additional namespaces referenced by `aadPolicies[].namespace`.

- `aadPolicies`  
  Each entry becomes an `AuthorizationPolicy`:
  - `name: ns-all`, `namespaceWide: true` → policy applies to **all** workloads
    in namespace `ai`. Because `allowSameNamespaceInternal: true`, requests
    originating from the same namespace are allowed even without a JWT.
  - `name: runtime-openai` with `allowedPaths: ["/docs"]`  
    Adds an extra rule that allows `/docs` without JWT, while everything else
    still goes through the namespace-wide policy.

- `istio.*`  
  Controls creation of a `VirtualService`:
  - `host: ai.example.com`
  - `gateway: istio-system/ai-workloads-gateway`
  - `basePath: /apps` – all app paths are rooted under `/apps/<app-name>`
    unless you override `service.pathPrefix` on the app.

#### Apps

Under `ai-workloads.apps`:

1. **runtime-openai** (`kind: mlserver`)

   - Standard MLServer kind: defaults command, args, probes and settings mount.
   - Exposes port `8000` via a ClusterIP service.
   - Scales between 1 and 10 replicas based on CPU.

2. **librechat-backend** (`kind: librechat`)

   - ClusterIP service on port `3000`.
   - `skipVirtualService: true` → **not** exposed via the shared Istio
     `VirtualService`; only reachable internally (e.g. from oauth2-proxy).
   - `OPENAI_API_BASE` is templated using `tpl` so that the ClusterIP service
     name for `runtime-openai` is computed correctly for each release:
     it points to `http://<runtime-openai-service>:8000/v1`.

3. **librechat** (`kind: oauth2-proxy`)

   - `oauth2-proxy` listens on port `4180` and redirects users to AAD for login.
   - `--upstream` is templated to call the `librechat-backend` service on port
     `3000`.
   - This service **is** exposed via the shared Istio `VirtualService` at:
     `https://ai.example.com/apps/librechat/...`.

Each app can also use `infraProfile`, `resources`, `labels`, `annotations`,
`envFrom`, `volumeMounts`, etc., exactly like any other ai-workloads app.
