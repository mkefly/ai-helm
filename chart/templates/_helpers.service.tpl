{{/* DRY Service renderer for any app */}}
{{- define "ai-workloads.serviceTemplate" -}}
{{- $root := .root -}}
{{- $app := .app -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "ai-workloads.appName" (dict "root" $root "app" $app) }}
  labels:
{{ include "ai-workloads.standardLabels" (dict "root" $root "name" $app.name "component" ($app.kind | default "app") "extraLabels" $app.labels) | indent 4 }}
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
