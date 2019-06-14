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
    - Otherwise, use "product" from values.yaml (this is a require setting).
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
Create a namespace for an SRS gateway custom resource. The configured
"namespace" in values.yaml is set to lower case, trailing '-' characters
are trimmed, and the result is truncated at 63 characters since some
Kubernetes name fields are limited to this length.
*/}}
{{- define "srs-gateway.createNamespace" -}}
{{- print .Values.namespace | lower | trimSuffix "-" | trunc 63 -}}
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
{{- else -}}
{{- printf "%s-srs-creds-secret" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- end -}}
{{- end -}}

{{/*
Create an Docker registry secret resource name.
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
{{- else -}}
{{- printf "%s-docker-secret" .Values.product | lower | trimSuffix "-" | trunc 63 -}}
{{- end -}}
{{- end -}}

{{/*
Create the JSON data for a Kubernetes imagePullSecret.
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"https://index.docker.io/v1/\": {\"username\": \"%s\", \"password\": \"%s\", \"auth\": \"%s\"}}}" .Values.dockerUsername .Values.dockerPassword (printf "%s:%s" .Values.dockerUsername .Values.dockerPassword | b64enc) | b64enc }}
{{- end }}
