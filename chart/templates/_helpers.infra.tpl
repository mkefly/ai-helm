{{- define "ai-workloads.infraProfile" -}}
{{- $values := .Values -}}
{{- $obj := .app -}}
{{- $profiles := $values.infraProfiles | default dict -}}
{{- $name := $obj.infraProfile | default "default" -}}
{{- index $profiles $name | default dict | toYaml -}}
{{- end -}}
