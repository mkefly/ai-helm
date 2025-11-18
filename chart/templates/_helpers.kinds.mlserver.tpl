{{/*
Kind-specific defaults for kind: mlserver.

Responsibilities:
  - Ensure there is a Service (enabled by default) on port 8000 if none defined
  - Derive MLSERVER_HTTP_PORT from the first service port, unless already set
  - Provide sensible default liveness/readiness probes using the HTTP port
  - Provide a default command/args to start mlserver with /etc/settings/settings.json
  - Ensure a writable /models (emptyDir) by default
  - For mlserver workloads, add `azure.workload.identity/use: "true"` label
  - If no HPA defined at all, add a sane default HPA config
*/}}
{{- define "ai-workloads.applyKindDefaults.mlserver" -}}
{{- $root := .root -}}
{{- $in := .obj -}}

{{- /* Start with a shallow copy so we can mutate safely */}}
{{- $app := deepCopy $in -}}

{{- /* Ensure labels map exists */}}
{{- if not $app.labels }}
  {{- $_ := set $app "labels" (dict) }}
{{- end }}

{{- /* Mark mlserver workloads for Workload Identity (if your webhook uses this label) */}}
{{- if not (hasKey $app.labels "azure.workload.identity/use") }}
  {{- $_ := set $app.labels "azure.workload.identity/use" "true" }}
{{- end }}

{{- /* Ensure service block exists */}}
{{- if not $app.service }}
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

{{- /* Ensure env list exists */}}
{{- if not $app.env }}
  {{- $_ := set $app "env" (list) }}
{{- end }}
{{- $env := $app.env | default (list) }}

{{- /* Derive effective HTTP port from first service port */}}
{{- $ports := $svc.ports | default (list) -}}
{{- $portVal := 8000 -}}
{{- if gt (len $ports) 0 }}
  {{- $httpPort := index $ports 0 }}
  {{- $portVal = $httpPort.port | default 8000 }}
{{- end }}

{{- /* Check if MLSERVER_HTTP_PORT already defined */}}
{{- $hasPortEnv := false -}}
{{- range $e := $env }}
  {{- if eq ($e.name | default "") "MLSERVER_HTTP_PORT" }}
    {{- $hasPortEnv = true }}
  {{- end }}
{{- end }}

{{- /* Append MLSERVER_HTTP_PORT only if not already present */}}
{{- if not $hasPortEnv }}
  {{- $_ := set $app "env" (append $env (dict
        "name"  "MLSERVER_HTTP_PORT"
        "value" (printf "%v" $portVal)
      )) }}
{{- end }}

{{- /* Default liveness/readiness probes using the effective HTTP port */}}
{{- if not $app.livenessProbe }}
  {{- $_ := set $app "livenessProbe" (dict
        "httpGet"             (dict "path" "/v2/health/live"  "port" $portVal)
        "initialDelaySeconds" 10
        "periodSeconds"       15
        "timeoutSeconds"      2
      ) }}
{{- end }}

{{- if not $app.readinessProbe }}
  {{- $_ := set $app "readinessProbe" (dict
        "httpGet"             (dict "path" "/v2/health/ready" "port" $portVal)
        "initialDelaySeconds" 5
        "periodSeconds"       10
        "timeoutSeconds"      2
      ) }}
{{- end }}

{{- /* Ensure MLServer pods always get a writable /models (emptyDir) by default */}}
{{- if not $app.volumeMounts }}
  {{- $_ := set $app "volumeMounts" (list) }}
{{- end }}

{{- if not $app.volumes }}
  {{- $_ := set $app "volumes" (list) }}
{{- end }}

{{- $modelsMountPath := "/models" -}}
{{- $modelVolumeName := "" -}}
{{- $volumeMounts := $app.volumeMounts | default (list) -}}
{{- $volumes := $app.volumes | default (list) -}}
{{- $hasModelMount := false -}}

{{- range $mount := $volumeMounts -}}
  {{- if eq ($mount.mountPath | default "") $modelsMountPath -}}
    {{- $hasModelMount = true -}}
    {{- if eq $modelVolumeName "" -}}
      {{- $modelVolumeName = ($mount.name | default "") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if not $hasModelMount -}}
  {{- if eq $modelVolumeName "" -}}
    {{- $modelVolumeName = "model-storage" -}}
  {{- end -}}
  {{- $_ := set $app "volumeMounts" (append $volumeMounts (dict
        "name"      $modelVolumeName
        "mountPath" $modelsMountPath
      )) }}
{{- else -}}
  {{- if eq $modelVolumeName "" -}}
    {{- $modelVolumeName = "model-storage" -}}
  {{- end -}}
{{- end -}}

{{- $hasModelVolume := false -}}
{{- range $vol := $volumes -}}
  {{- if eq ($vol.name | default "") $modelVolumeName -}}
    {{- $hasModelVolume = true -}}
  {{- end -}}
{{- end -}}

{{- if not $hasModelVolume }}
  {{- $_ := set $app "volumes" (append $volumes (dict
        "name"     $modelVolumeName
        "emptyDir" (dict)
      )) }}
{{- end }}

{{- /* Default command/args for mlserver */}}
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
