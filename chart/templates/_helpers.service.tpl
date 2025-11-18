{{/* DRY Service renderer for any app */}}
{{- define "ai-workloads.serviceTemplate" -}}
{{- $root := .root -}}
{{- $app := .app -}}
{{- $annotations := .annotations | default dict -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "ai-workloads.appName" (dict "root" $root "app" $app) }}
  labels:
{{ include "ai-workloads.standardLabels" (dict "root" $root "name" $app.name "component" ($app.kind | default "app") "extraLabels" $app.labels) | indent 4 }}
{{- if gt (len $annotations) 0 }}
  annotations:
{{ toYaml $annotations | indent 4 }}
{{- end }}
spec:
  type: {{ .type }}
  selector:
    app.kubernetes.io/name: {{ $app.name }}
    app.kubernetes.io/instance: {{ $root.Release.Name }}
  ports:
{{- range $i, $p := .ports }}
    - name: {{ default (printf "port-%d" $i) $p.name }}
      port: {{ $p.port }}
      targetPort: {{ default $p.targetPort $p.port }}
      protocol: {{ default "TCP" $p.protocol }}
{{- if $p.appProtocol }}
      appProtocol: {{ $p.appProtocol }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Resolve the most appropriate HTTP port for a Service */}}
{{- define "ai-workloads.serviceHttpPort" -}}
{{- $svc := .service | default dict -}}
{{- $ports := $svc.ports | default (list) -}}
{{- $state := dict "port" nil -}}

{{- range $ports }}
  {{- if and (not $state.port) (eq (.name | default "") "http") }}
    {{- $_ := set $state "port" .port }}
  {{- end }}
{{- end }}

{{- if not $state.port }}
  {{- if gt (len $ports) 0 }}
    {{- $_ := set $state "port" ((index $ports 0).port) }}
  {{- end }}
{{- end }}

{{- if $state.port }}
{{ $state.port }}
{{- end }}
{{- end -}}
