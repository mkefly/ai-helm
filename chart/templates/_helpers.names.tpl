{{/* Chart fullname: <release>-<chart> */}}
{{- define "ai-workloads.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Build resource name for an app/task: <fullname>-<name> */}}
{{- define "ai-workloads.appName" -}}
{{- $root := .root -}}
{{- $obj := .app -}}
{{- printf "%s-%s" (include "ai-workloads.fullname" $root) $obj.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Effective serviceAccountName */}}
{{- define "ai-workloads.serviceAccountName" -}}
{{- $ := . -}}
{{- if $.Values.serviceAccount.create -}}
  {{- if $.Values.serviceAccount.name -}}
{{ $.Values.serviceAccount.name }}
  {{- else -}}
{{ printf "%s-sa" (include "ai-workloads.fullname" $) }}
  {{- end -}}
{{- else -}}
default
{{- end -}}
{{- end -}}
