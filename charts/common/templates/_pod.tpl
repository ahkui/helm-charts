{{- define "common.pod" -}}
serviceAccountName: {{ include "common.serviceAccountName" . }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}

{{- with .Values.imagePullSecrets }}
imagePullSecrets: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.podSecurityContext }}
securityContext: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.initContainers }}
initContainers: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end }}

containers:
  - name: {{ include "common.name" . }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}

    {{- with .Values.securityContext }}
    securityContext: {{ include "bettertpl" (dict "value" . "context" $) | nindent 6 }}
    {{- end -}}

    {{- with .Values.args }}
    args: {{ include "bettertpl" (dict "value" . "context" $) | nindent 6 }}
    {{- end -}}

    {{- with .Values.service.ports }}
    ports:
      {{- range $key, $port := . }}
      {{- if or $port.enabled (eq $port.enabled nil) }}
      - name: {{ $key }}
        containerPort: {{ $port.containerPort }}
        protocol: {{ $port.protocol }}
        {{- with $port.hostPort }}
        hostPort: {{ . }}
        {{- end }}
      {{- end }}
      {{- end }}
    {{- end -}}

    {{- with .Values.resources }}
    resources: {{ include "bettertpl" (dict "value" . "context" $) | nindent 6 }}
    {{- end -}}

    {{- with .Values.lifecycle }}
    lifecycle: {{ include "bettertpl" (dict "value" . "context" $) | nindent 6 }}
    {{- end -}}

    {{- with .Values.startupProbe }}
    {{- if or .enabled (eq .enabled nil) }}
    startupProbe: {{ include "bettertpl" (dict "value" (omit . "enabled") "context" $) | nindent 6 }}
    {{- end }}
    {{- end -}}

    {{- with .Values.livenessProbe }}
    {{- if or .enabled (eq .enabled nil) }}
    livenessProbe: {{ include "bettertpl" (dict "value" (omit . "enabled") "context" $) | nindent 6 }}
    {{- end }}
    {{- end -}}

    {{- with .Values.readinessProbe }}
    {{- if or .enabled (eq .enabled nil) }}
    readinessProbe: {{ include "bettertpl" (dict "value" (omit . "enabled") "context" $) | nindent 6 }}
    {{- end }}
    {{- end -}}

    {{- with .Values.env }}
    env:
      {{- range $k, $v := . }}
      - name: {{ $k }}
        value: {{ include "bettertpl" (dict "value" $v "context" $) | quote }}
      {{- end }}
    {{- end -}}

    {{- with .Values.envFrom }}
    envFrom:
      {{- range $k, $v := . }}
      {{- if $v.configMapRef }}
      - configMapRef:
          name: {{ include "bettertpl" (dict "value" $v.configMapRef "context" $) }}
          optional: {{ $v.optional | default false }}
      {{- else if $v.secretRef }}
      - secretRef:
          name: {{ include "bettertpl" (dict "value" $v.secretRef "context" $) }}
          optional: {{ $v.optional | default false }}
      {{- end }}
      {{- end }}
    {{- end -}}

    {{- with .Values.volumeMounts }}
    volumeMounts:
      {{- range $k, $v := . }}
      {{- if and $v.mountPath (not $v.sidecarOnly)  }}
      - name: {{ $v.name | quote }}
        mountPath: {{ $v.mountPath | quote }}
        {{- if $v.subPath }}
        subPath: {{ $v.subPath | quote }}
        {{- end }}
        readOnly: {{ $v.readOnly | default false }}
      {{- end }}
      {{- end }}
    {{- end -}}

  {{- with .Values.extraContainers }}
  {{- include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
  {{- end -}}

{{- with .Values.volumeMounts }}
volumes:
  {{- range $k, $v := . }}
  {{- if or $v.configMapRef $v.secretRef }}
  - name: {{ $v.name | quote }}
    {{- if $v.secretRef }}
    secret:
      secretName: {{ include "bettertpl" (dict "value" $v.secretRef "context" $) }}
      optional: {{ $v.optional | default false }}
    {{- else if $v.configMapRef }}
    configMap:
      name: {{ include "bettertpl" (dict "value" $v.configMapRef "context" $) }}
      optional: {{ $v.optional | default false }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end -}}

{{- with .Values.priorityClassName }}
priorityClassName: {{ . | quote }}
{{- end -}}

{{- with .Values.nodeSelector }}
nodeSelector: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.affinity }}
affinity: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.tolerations }}
tolerations: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints: {{ include "bettertpl" (dict "value" . "context" $) | nindent 2 }}
{{- end -}}

{{- with .Values.hostAliases }}
hostAliases: {{ . | toYaml | nindent 2 }}
{{- end -}}

{{- end }}
