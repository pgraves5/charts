#
# Copyright © 2020 Dell Inc. or its subsidiaries. All Rights Reserved.
#
# This software contains the intellectual property of Dell Inc.
# or is licensed to Dell Inc. from third parties. Use of this software
# and the intellectual property contained therein is expressly limited to the
# terms and conditions of the License Agreement under which it is provided by or
# on behalf of Dell Inc. or its subsidiaries.

ARG KUBECTL_BINARY=kubectl-linux-amd64-1.18.10
ARG APP_YAMLS="./temp_package/yaml/apps"
# Dockerfile for install-controller

FROM asdrepo.isus.emc.com:8099/install-controller:latest

COPY $KUBECTL_BINARY /usr/local/bin/kubectl
RUN  chmod +x /usr/local/bin/kubectl

RUN  mkdir -p ./apps 
COPY ${APP_YAMLS} ./apps

COPY ./docs /docs

COPY ./scripts/install-controller-entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh
