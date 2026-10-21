{{/*
Expand the name of the chart.
*/}}
{{- define "downloader-general.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "downloader-general.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "downloader-general.labels" -}}
helm.sh/chart: {{ include "downloader-general.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "downloader-general.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "downloader-general.selectorLabels" -}}
app.kubernetes.io/name: {{ include "downloader-general.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
