{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "srs-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "srs-gateway.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "srs-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create an SRS gateway custom resource name.
The order of precedence for deciding what name to use is as follows:
    - If "customResourceName" is set in values.yaml, then use that.
    - Otherwise, use "product" from values.yaml (this is a required setting).
The name selected is set to lower case, trailing '-' are trimmed, and
the result is truncated at 63 characters since some Kubernetes name
fields are limited to this length.
*/}}
{{- define "srs-gateway.createCustomResourceName" -}}
{{- if .Values.customResourceName -}}
{{- print .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{- print .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- end -}}
{{- end -}}

{{/*
Create an SRS gateway credentials secret resource name.
The order of precedence for deciding what name to use is as follows:
    - If "customResourceName" is set in values.yaml, use that with
      a "-srs-creds-secret" suffix.
    - Otherwise, use "product" from values.yaml, with a "-srs-creds-secret"
      suffix.
The name selected is set to lower case, trailing '-' are trimmed, and
the result is truncated at 63 characters since some Kubernetes name
fields are limited to this length.
*/}}
{{- define "srs-gateway.createCredsSecretName" -}}
{{- if .Values.customResourceName -}}
{{- printf "%s-srs-creds-secret" .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.product -}}
{{- printf "%s-srs-creds-secret" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{/*
This case should never occur, since .Values.product is a required setting.
This is added solely to satisfy `helm lint`.
*/}}
{{- printf "srs-creds-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Create a Docker registry secret resource name.
The order of precedence for deciding what name to use is as follows:
    - If "dockerSecret" is set in values.yaml, use that directly.
    - Else, if "customResourceName" is set in values.yaml, use that with a
      "-docker-secret" suffix:
            <customResourceName>-docker-secret
    - Else, use "product" from values.yaml, with a "-docker-secret"
      suffix:
            <product>-docker-secret
The name selected is set to lower case, trailing '-' are trimmed, and
the result is truncated at 63 characters since some Kubernetes name
fields are limited to this length.
*/}}
{{- define "srs-gateway.createDockerSecretName" -}}
{{- if .Values.dockerSecret -}}
{{- print .Values.dockerSecret | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.customResourceName -}}
{{- printf "%s-docker-secret" .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.product -}}
{{- printf "%s-docker-secret" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{/*
This case should never occur, since .Values.product is a required setting.
This is added solely to satisfy `helm lint`.
*/}}
{{- printf "srs-docker-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Create a name for the Remote Access serviceaccount.
The order of precedence for deciding what prefix to use is as follows:
    - If "customResourceName" is set in values.yaml, then use that.
    - Otherwise, use "product" from values.yaml (this is a required setting).
The selected prefix is concatenated with "-remote-access", and he result
is set to lower case, trailing '-' are trimmed, and the result is truncated
at 63 characters since some Kubernetes name fields are limited to this length.
*/}}
{{- define "srs-gateway.remoteAccessServiceAccountName" -}}
{{- if .Values.customResourceName -}}
{{- printf "%s-remote-access" .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.product -}}
{{- printf "%s-remote-access" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{/*
This case should never occur, since .Values.product is a required setting.
This is added solely to satisfy `helm lint`.
*/}}
{{- printf "srs-remote-access" -}}
{{- end -}}
{{- end -}}

{{/*
Create a name for the Notifier deployment serviceaccount.
The order of precedence for deciding what prefix to use is as follows:
    - If "customResourceName" is set in values.yaml, then use that.
    - Otherwise, use "product" from values.yaml (this is a required setting).
The selected prefix is concatenated with "-srs-notifier", and he result
is set to lower case, trailing '-' are trimmed, and the result is truncated
at 63 characters since some Kubernetes name fields are limited to this length.
*/}}
{{- define "srs-gateway.notifierServiceAccountName" -}}
{{- if .Values.customResourceName -}}
{{- printf "%s-srs-notifier" .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.product -}}
{{- printf "%s-srs-notifier" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{/*
This case should never occur, since .Values.product is a required setting.
This is added solely to satisfy `helm lint`.
*/}}
{{- printf "srs-notifier" -}}
{{- end -}}
{{- end -}}

{{/*
Create a name for the config-upload deployment serviceaccount.
The order of precedence for deciding what prefix to use is as follows:
    - If "customResourceName" is set in values.yaml, then use that.
    - Otherwise, use "product" from values.yaml (this is a required setting).
The selected prefix is concatenated with "-config-upload", and he result
is set to lower case, trailing '-' are trimmed, and the result is truncated
at 63 characters since some Kubernetes name fields are limited to this length.
*/}}
{{- define "srs-gateway.configUploadServiceAccountName" -}}
{{- if .Values.customResourceName -}}
{{- printf "%s-config-upload" .Values.customResourceName | lower | trimSuffix "-" | trunc 63 -}}
{{- else if .Values.product -}}
{{- printf "%s-config-upload" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- else -}}
{{/*
This case should never occur, since .Values.product is a required setting.
This is added solely to satisfy `helm lint`.
*/}}
{{- printf "srs-config-upload" -}}
{{- end -}}
{{- end -}}

{{/*
Create the JSON data for a Kubernetes imagePullSecret.
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"https://index.docker.io/v1/\": {\"username\": \"%s\", \"password\": \"%s\", \"auth\": \"%s\"}}}" .Values.dockerUsername .Values.dockerPassword (printf "%s:%s" .Values.dockerUsername .Values.dockerPassword | b64enc) | b64enc }}
{{- end }}
