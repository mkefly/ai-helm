{{- define "ai-workloads.settingsConfigMap" -}}
{{- $root := .root -}}
{{- $obj := .obj -}}
{{- $component := .component -}}
{{- if and $obj.settings (not $obj.settingsConfigMapName) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "ai-workloads.appName" (dict "root" $root "app" $obj) }}-settings
  labels:
{{ include "ai-workloads.standardLabels" (dict "root" $root "name" $obj.name "component" $component "extraLabels" $obj.labels) | indent 4 }}
data:
  settings.json: |
{{ $obj.settings | indent 4 }}
---
{{- end }}
{{- end -}}

{{- /* Hash content used for app/task settings so that pods restart on updates */ -}}
{{- define "ai-workloads.settingsChecksum" -}}
{{- $obj := .obj -}}
{{- if $obj.settings }}
{{- printf "%s" $obj.settings | sha256sum -}}
{{- else if $obj.settingsConfigMapName }}
{{- printf "%s" $obj.settingsConfigMapName | sha256sum -}}
{{- end -}}
{{- end -}}
