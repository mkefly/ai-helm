{{/*
Apply kind-specific defaults (mlserver, etc.) to an app definition,
so that renderers can stay generic and not care about .kind.

Usage:
  {{- $appYaml := include "ai-workloads.applyKindDefaults" (dict "root" . "obj" $raw) -}}
  {{- $app := fromYaml $appYaml -}}
*/}}
{{- define "ai-workloads.applyKindDefaults" -}}
{{- $root := .root -}}
{{- $in := .obj -}}
{{- $kind := $in.kind | default "" -}}

{{- if eq $kind "mlserver" -}}
  {{- include "ai-workloads.applyKindDefaults.mlserver" (dict "root" $root "obj" $in) -}}
{{- else -}}
  {{ toYaml $in }}
{{- end -}}
{{- end -}}
