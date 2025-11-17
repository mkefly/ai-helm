{{- define "ai-workloads.podSpec" -}}
{{- $root := .root -}}
{{- $obj := .obj -}}
{{- $profile := .profile -}}
{{- $restartPolicy := .restartPolicy -}}

{{- if and (or $obj.settings $obj.settingsConfigMapName) (not $obj.settingsMountPath) }}
  {{- $_ := set $obj "settingsMountPath" "/etc/settings" }}
{{- end }}

serviceAccountName: {{ include "ai-workloads.serviceAccountName" $root }}
restartPolicy: {{ $restartPolicy }}
{{- if $root.Values.global.imagePullSecrets }}
imagePullSecrets:
{{ toYaml $root.Values.global.imagePullSecrets | indent 2 }}
{{- end }}

{{- with $root.Values.podSecurityContext }}
{{- if . }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{- with $profile.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}

{{- with $profile.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}

{{- with $profile.affinity }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}

{{- if $obj.priorityClassName }}
priorityClassName: {{ $obj.priorityClassName | quote }}
{{- end }}

{{- with $obj.initContainers }}
initContainers:
{{ toYaml . | indent 2 }}
{{- end }}

containers:
  - name: {{ $obj.name }}
    image: "{{ $obj.image.repository }}:{{ $obj.image.tag }}"
    imagePullPolicy: {{ $obj.image.pullPolicy | default "IfNotPresent" }}
{{- with $root.Values.containerSecurityContext }}
{{- if . }}
    securityContext:
{{ toYaml . | indent 4 }}
{{- end }}
{{- end }}
{{- if $obj.command }}
    command:
{{ toYaml $obj.command | indent 6 }}
{{- end }}
{{- if $obj.args }}
    args:
{{ toYaml $obj.args | indent 6 }}
{{- end }}
{{- if $obj.env }}
    env:
{{- range $e := $obj.env }}
      - name: {{ $e.name }}
{{- if hasKey $e "value" }}
        value: {{ tpl $e.value $root | quote }}
{{- else if hasKey $e "valueFrom" }}
        valueFrom:
{{ toYaml $e.valueFrom | indent 10 }}
{{- end }}
{{- end }}
{{- end }}
{{- if $obj.envFrom }}
    envFrom:
{{ toYaml $obj.envFrom | indent 6 }}
{{- end }}
{{- if $obj.livenessProbe }}
    livenessProbe:
{{ toYaml $obj.livenessProbe | indent 6 }}
{{- end }}
{{- if $obj.readinessProbe }}
    readinessProbe:
{{ toYaml $obj.readinessProbe | indent 6 }}
{{- end }}
{{- if $obj.startupProbe }}
    startupProbe:
{{ toYaml $obj.startupProbe | indent 6 }}
{{- end }}
{{- if $obj.resources }}
    resources:
{{ toYaml $obj.resources | indent 6 }}
{{- else if $profile.resources }}
    resources:
{{ toYaml $profile.resources | indent 6 }}
{{- end }}

{{- /* Decide if we need the settings volume + mount */}}
{{- $needSettingsVolume := or $obj.settings $obj.settingsConfigMapName }}
{{- $needSettingsMount := and $obj.settingsMountPath $needSettingsVolume }}

{{- if or $obj.volumeMounts $needSettingsMount }}
    volumeMounts:
{{- if $obj.volumeMounts }}
{{ toYaml $obj.volumeMounts | indent 6 }}
{{- end }}
{{- if $needSettingsMount }}
      - name: app-settings
        mountPath: {{ $obj.settingsMountPath | quote }}
{{- end }}
{{- end }}

{{- if $obj.sidecarContainers }}
{{ toYaml $obj.sidecarContainers | indent 2 }}
{{- end }}

{{- if or $obj.volumes $needSettingsVolume }}
volumes:
{{- if $obj.volumes }}
{{ toYaml $obj.volumes | indent 2 }}
{{- end }}
{{- if $needSettingsVolume }}
  - name: app-settings
    configMap:
      name: {{ default (printf "%s-settings" (include "ai-workloads.appName" (dict "root" $root "app" $obj))) $obj.settingsConfigMapName | quote }}
{{- end }}
{{- end }}
{{- end -}}
