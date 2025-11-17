{{- define "ai-workloads.standardLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component | default "app" }}
app.kubernetes.io/managed-by: "ai-workloads-helm"
app.kubernetes.io/part-of: {{ .root.Chart.Name }}
{{- with .root.Values.metadata.labels }}
{{ toYaml . | nindent 0 }}
{{- end }}
{{- with .extraLabels }}
{{ toYaml . | nindent 0 }}
{{- end }}
{{- end -}}
