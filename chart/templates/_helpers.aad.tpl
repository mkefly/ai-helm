{{/* AAD helpers */}}
{{- define "aad-guard.fullname" -}}
{{- include "ai-workloads.fullname" . -}}
{{- end -}}

{{- define "aad-guard.apiAudience" -}}
{{- $aad := .Values.aad | default dict -}}
{{- $aud := $aad.apiAudience | default (index ($aad.audiences | default (list "")) 0) -}}
{{- $aud | default "" -}}
{{- end -}}

{{- define "aad-guard.requestauth.name" -}}
{{ printf "%s-aad-requestauth" (include "ai-workloads.fullname" .) }}
{{- end -}}

{{- define "aad-guard.issuer" -}}
{{- $aad := .Values.aad | default dict -}}
{{- if $aad.tenantId -}}
{{ printf "https://login.microsoftonline.com/%s/v2.0" $aad.tenantId }}
{{- end -}}
{{- end -}}

{{- define "aad-guard.jwksUri" -}}
{{- $aad := .Values.aad | default dict -}}
{{- if $aad.tenantId -}}
{{ printf "https://login.microsoftonline.com/%s/discovery/v2.0/keys" $aad.tenantId }}
{{- end -}}
{{- end -}}
