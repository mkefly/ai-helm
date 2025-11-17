{{/*
Kind-specific defaults for kind: mlserver.

Responsibilities:
  - Ensure there is a Service (enabled by default) on port 8000 if none defined
  - Derive MLSERVER_HTTP_PORT from the first service port
  - Provide sensible default liveness/readiness probes
  - Provide a default command/args to start mlserver with /etc/settings/settings.json
*/}}
{{- define "ai-workloads.applyKindDefaults.mlserver" -}}
{{- $root := .root -}}
{{- $in := .obj -}}

{{- /* Start with a shallow copy so we can mutate safely */}}
{{- $app := deepCopy $in -}}

{{- if not $app.service }}
  {{- /* Ensure service exists */}}
  {{- $_ := set $app "service" (dict) }}
{{- end }}

{{- /* Convenience local */}}
{{- $svc := $app.service -}}

{{- /* Enable service by default if not explicitly set */}}
{{- if not (hasKey $svc "enabled") }}
  {{- $_ := set $svc "enabled" true }}
{{- end }}

{{- /* Default Service ports: HTTP on 8000 */}}
{{- if not $svc.ports }}
  {{- $defaultPorts := list (dict
        "name"       "http"
        "port"       8000
        "targetPort" 8000
        "protocol"   "TCP"
      ) }}
  {{- $_ := set $svc "ports" $defaultPorts }}
{{- end }}

{{- if not $app.env }}
  {{- $_ := set $app "env" (list) }}
{{- end }}

{{- $ports := $svc.ports | default (list) }}

{{- if gt (len $ports) 0 }}
  {{- /* Use the first declared port as the HTTP port */}}
  {{- $httpPort := index $ports 0 }}
  {{- $portVal := $httpPort.port | default 8000 }}

  {{- /* Append MLSERVER_HTTP_PORT */}}
  {{- $_ := set $app "env" (append $app.env (dict
        "name"  "MLSERVER_HTTP_PORT"
        "value" (printf "%v" $portVal)
      )) }}
{{- end }}

{{- if not $app.livenessProbe }}
  {{- $_ := set $app "livenessProbe" (dict
        "httpGet"             (dict "path" "/v2/health/live"  "port" 8000)
        "initialDelaySeconds" 10
        "periodSeconds"       15
        "timeoutSeconds"      2
      ) }}
{{- end }}

{{- if not $app.readinessProbe }}
  {{- $_ := set $app "readinessProbe" (dict
        "httpGet"             (dict "path" "/v2/health/ready" "port" 8000)
        "initialDelaySeconds" 5
        "periodSeconds"       10
        "timeoutSeconds"      2
      ) }}
{{- end }}

{{- if and (not $app.command) (not $app.args) }}
  {{- $_ := set $app "command" (list "mlserver") }}
  {{- $_ := set $app "args" (list
        "start"
        "--settings"
        "/etc/settings/settings.json"
      ) }}
{{- end }}

{{- /* Default settingsMountPath for mlserver if we have settings but no mount path */}}
{{- if and $app.settings (not $app.settingsMountPath) }}
  {{- $_ := set $app "settingsMountPath" "/etc/settings" }}
{{- end }}

{{ toYaml $app }}
{{- end -}}
