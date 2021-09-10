{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "objectscale-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "objectscale-manager.fullname" -}}
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
{{- define "objectscale-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{ define "topologyNodeAffinity" -}}
{{- if or (and .Values.global.topology.excludedFaultDomains .Values.global.topology.faultDomainKey) .Values.global.topology.nodeSelector }}
topologyNodeAffinity:
{{- include "nodeAffinityInternal" . }}
{{- end }}
{{- end -}}

{{ define "nodeAffinity" -}}
{{- if or (and .Values.global.topology.excludedFaultDomains .Values.global.topology.faultDomainKey) .Values.global.topology.nodeSelector }}
nodeAffinity:
{{- include "nodeAffinityInternal" . }}
{{- end }}
{{- end -}}

{{ define "nodeAffinityInternal" }}
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      # exclude any fault domains that the customer doesn't want in the
      # node selectors
      {{- if and .Values.global.topology.excludedFaultDomains .Values.global.topology.faultDomainKey }}
      - key: {{.Values.global.topology.faultDomainKey}}
        operator: NotIn
        values:
        {{- range .Values.global.topology.excludedFaultDomains }}
        - {{ . }}
        {{- end }}
      {{- end }}
      # Limit scheduling to only those listed in the node selector
      # if we want this to be a multi-select list, we could actually do that
      # just as easily
      {{- if .Values.global.topology.nodeSelector }}
      - key: {{.Values.global.topology.nodeSelector.key }}
        operator: In
        values:
        - {{ .Values.global.topology.nodeSelector.value }}
      {{- end }}
{{- end -}}
