HELM_VERSION := v3.5.3
HELM_URL     := https://get.helm.sh
HELM_TGZ      = helm-${HELM_VERSION}-linux-amd64.tar.gz
YQ_VERSION   := 4.4.1
YAMLLINT_VERSION := 1.20.0
ALL_CHARTS := common-lib openshift-scc ecs-cluster objectscale-manager mongoose zookeeper-operator atlas-operator decks kahm dks-testapp fio-test sonobuoy dellemc-license service-pod helm-controller objectscale-graphql objectscale-vsphere objectscale-portal objectscale-gateway objectscale-iam pravega-operator bookkeeper-operator supportassist decks-support-store statefuldaemonset-operator influxdb-operator objectscale-federation logging-injector objectscale-dcm snmp-notifier
CHARTS = ${ALL_CHARTS}
DECKSCHARTS := decks kahm supportassist service-pod dellemc-license decks-support-store snmp-notifier
FLEXCHARTS := common-lib openshift-scc ecs-cluster objectscale-manager objectscale-vsphere objectscale-graphql helm-controller objectscale-portal objectscale-gateway objectscale-iam statefuldaemonset-operator influxdb-operator objectscale-federation logging-injector objectscale-dcm

# release version
MAJOR=0
MINOR=79
PATCH=0
PRERELEASE=1223

FULL_PACKAGE_VERSION=${MAJOR}.${MINOR}.${PATCH}$(if $(PRERELEASE),-$(PRERELEASE),)
FLEXVER=${FULL_PACKAGE_VERSION}
DECKSVER=2.${MINOR}.${PATCH}$(if $(PRERELEASE),-$(PRERELEASE),)


GIT_COMMIT_COUNT=$(shell git rev-list HEAD | wc -l)
GIT_COMMIT_ID=$(shell git rev-parse HEAD)
GIT_COMMIT_SHORT_ID=$(shell git rev-parse --short HEAD)
GIT_BRANCH_ID=$(shell git rev-parse --abbrev-ref HEAD)
YQ_CMD_VERSION := $(shell yq --version | awk '{print $$3}')

# packaging
OBJS_VSPHERE_MANIFEST := objectscale-vsphere7-manifest.yaml
OBJS_MGR_MANIFEST   := objectscale-manager-app.yaml
KAHM_MANIFEST       := kahm-app.yaml
DECKS_MANIFEST      := decks-app.yaml
LOGGING_INJECTOR_MANIFEST := logging-injector-app.yaml
PACKAGE_NAME        := objectscale-charts-package.tgz
NAMESPACE            = dellemc-objectscale-system
TEMP_PACKAGE        := temp_package
SERVICE_ID           = objectscale
REGISTRY             = REGISTRYTEMPLATE
DECKS_REGISTRY       = REGISTRYTEMPLATE
KAHM_REGISTRY        = REGISTRYTEMPLATE
REGISTRYSECRET       = vsphere-docker-secret
STORAGECLASSNAME     = dellemc-${SERVICE_ID}-highly-available
STORAGECLASSNAME_VSAN_SNA     = dellemc-${SERVICE_ID}-vsan-sna-thick
VERSION_SLICE_PATH   = version_slice.json

WATCH_ALL_NAMESPACES = false # --set global.watchAllNamespaces={true | false}
HELM_MANAGER_ARGS    = # --set image.tag={YOUR_VERSION_HERE}
HELM_MONITORING_ARGS = # --set global.monitoring.tag=${YOUR_VERSION_HERE}
HELM_UI_ARGS         = # --set image.tag=${YOUR_VERSION_HERE}
HELM_GRAPHQL_ARGS    = # --set objectscale-graphql.tag=${YOUR_VERSION_HERE}
HELM_INSTALLER_ARGS  = # --set objectscale-graphql.helm-controller.tag=${YOUR_VERSION_HERE}
HELM_DECKS_ARGS      = # --set image.tag=${YOUR_VERSION_HERE}
HELM_KAHM_ARGS       = # --set image.tag=${YOUR_VERSION_HERE}
HELM_DECKS_SUPPORT_STORE_ARGS      = # --set decks-support-store.image.tag=${YOUR_VERSION_HERE}
SED_INPLACE         := -i
ENABLE_STDOUT_LOGS_COLLECTION   := false

DOCKER_LABELS := --label "GIT_BRANCH=${GIT_BRANCH_ID}" --label "VERSION=${FLEXVER}" --label "PRODUCT_VERSION=${FULL_PACKAGE_VERSION}" --label "GITSHA=${GIT_COMMIT_SHORT_ID}"

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	SED_INPLACE += .orig
endif

ISSUE_EVENTS_RAW     = ${TEMP_PACKAGE}/yaml/issues_events_${FLEXVER}.yaml
ISSUE_EVENTS_REPORT  = ${TEMP_PACKAGE}/yaml/issues_events_${FLEXVER}.json

clean: clean-package
	rm -rf ./docs

all: test package

release: decksver flexver build generate-issues-events-all

resolve-and-release: decksver flexver resolve-versions build generate-issues-events-all

test:
	helm version
	yamllint --version
	helm lint ${CHARTS} --set product=objectscale --set global.product=objectscale
	yamllint -c .yamllint.yml */Chart.yaml */values.yaml
	yamllint -c .yamllint-crd.yml */crds/*.yaml
	yamllint -c .yamllint.yml -s .yamllint.yml .travis.yml
	helm unittest ${CHARTS}

dep:
	wget -q ${HELM_URL}/${HELM_TGZ}
	tar xzf ${HELM_TGZ} -C /tmp --strip-components=1
	PATH=`pwd`/linux-amd64/:${PATH}
	chmod +x /tmp/helm
	helm plugin list | grep -q "unittest" ; \
	if [ "$${?}" -eq "1" ] ; then \
		helm plugin install https://github.com/lrills/helm-unittest ; \
 	fi
	export PATH=/tmp:${PATH}
	sudo pip install yamllint=="${YAMLLINT_VERSION}" requests
	wget -q http://asdrepo.isus.emc.com/artifactory/objectscale-build/com/github/yq/v${YQ_VERSION}/yq_linux_amd64
	sudo mv yq_linux_amd64 /usr/bin/yq
	sudo chmod u+x /usr/bin/yq

yqcheck:
ifneq (${YQ_VERSION},${YQ_CMD_VERSION})
	@echo "Requires yq version:${YQ_VERSION} found version:${YQ_CMD_VERSION}"
	@echo
	@echo "Run make dep to install 'yq'"
	@echo
	exit 1
endif

decksver: yqcheck
	if [ -z ${DECKSVER} ] ; then \
		echo "Missing DECKSVER= param" ; \
		exit 1 ; \
	fi

	for CHART in ${DECKSCHARTS}; do  \
		echo "Setting version ${DECKSVER} in $$CHART" ;\
		yq e '.appVersion = "${DECKSVER}"' -i $$CHART/Chart.yaml ; \
		yq e '.version = "${DECKSVER}"' -i $$CHART/Chart.yaml ; \
		sed ${SED_INPLACE} '1s/^/---\n/' $$CHART/Chart.yaml ; \
		sed ${SED_INPLACE} -e "0,/^tag.*/s//tag: ${DECKSVER}/"  $$CHART/values.yaml; \
	done ;

	for CHART in ${FLEXCHARTS} ${DECKSCHARTS}; do  \
		echo "Setting decks dep version ${DECKSVER} in $$CHART" ;\
		sed ${SED_INPLACE} -e "/no_auto_change__decks_auto_change/s/version:.*/version: ${DECKSVER} # no_auto_change__decks_auto_change/g"  $$CHART/Chart.yaml; \
		sed ${SED_INPLACE} -e "/no_auto_change__flex_auto_change/s/version:.*/version: ${FLEXVER} # no_auto_change__flex_auto_change/g"  $$CHART/Chart.yaml; \
	done ;

graphqlver: yqcheck
	yq e '(.objectStoreAvailableVersions[0] = "${FLEXVER}") | (.decks.licenseChartVersion = "${DECKSVER}") | (.decks.supportAssistChartVersion = "${DECKSVER}") ' -i objectscale-graphql/values.yaml
	sed ${SED_INPLACE} '1s/^/---\n/' objectscale-graphql/values.yaml
	yamllint -c .yamllint.yml objectscale-graphql/values.yaml

zookeeper-operatorver:
	sed ${SED_INPLACE} -e "/no_auto_change__flex_auto_change/s/version:.*/version: ${FLEXVER} # no_auto_change__flex_auto_change/g"  zookeeper-operator/Chart.yaml

pravega-operatorver:
	sed ${SED_INPLACE} -e "/no_auto_change__flex_auto_change/s/version:.*/version: ${FLEXVER} # no_auto_change__flex_auto_change/g"  pravega-operator/Chart.yaml

atlas-operatorver:
	sed ${SED_INPLACE} -e "/no_auto_change__flex_auto_change/s/version:.*/version: ${FLEXVER} # no_auto_change__flex_auto_change/g"  atlas-operator/Chart.yaml

bookkeeper-operatorver:
	sed ${SED_INPLACE} -e "/no_auto_change__flex_auto_change/s/version:.*/version: ${FLEXVER} # no_auto_change__flex_auto_change/g"  bookkeeper-operator/Chart.yaml

flexver: yqcheck graphqlver zookeeper-operatorver pravega-operatorver atlas-operatorver bookkeeper-operatorver
	if [ -z ${FLEXVER} ] ; then \
		echo "Missing FLEXVER= param" ; \
		exit 1 ; \
	fi
	for CHART in ${FLEXCHARTS}; do  \
		echo "Setting version $$FLEXVER in $$CHART" ;\
		yq e '.appVersion = "${FLEXVER}"' -i $$CHART/Chart.yaml ; \
		sed ${SED_INPLACE} -e "/no_auto_change/!s/version:.*/version: ${FLEXVER}/g"  $$CHART/Chart.yaml; \
		sed ${SED_INPLACE} '1s/^/---\n/' $$CHART/Chart.yaml ; \
		sed ${SED_INPLACE} -e "0,/^tag.*/s//tag: ${FLEXVER}/"  $$CHART/values.yaml; \
	done ;

chart-dep: charts-dep
charts-dep:
	rm -f **/charts/**; \
	rm -rf **/tmpcharts; \
	if [ "$${CHARTS}" = "$${ALL_CHARTS}" ] ; then \
		BUILD_CHARTS=`python tools/build_helper/sort_charts_by_deps.py -c ${CHARTS}`; \
	else  \
		BUILD_CHARTS=`python tools/build_helper/sort_charts_by_deps.py -c ${ALL_CHARTS} -s ${CHARTS}`; \
	fi ; \
 	for CHART in $${BUILD_CHARTS}; do \
 		echo "Updating dependencies for $${CHART}" ; \
 		helm dep up $${CHART} || exit $?; \
 	done ;

resolve-versions:
	python tools/build_helper/version_resolver.py -vs ${VERSION_SLICE_PATH}

build:
	if [ "$${CHARTS}" == "$${ALL_CHARTS}" ] ; then \
	    BUILD_CHARTS=`python tools/build_helper/sort_charts_by_deps.py -c ${CHARTS}`; \
	else  \
	    BUILD_CHARTS=`python tools/build_helper/sort_charts_by_deps.py -c ${ALL_CHARTS} -s ${CHARTS}`; \
	fi ; \
	for CHART in $${BUILD_CHARTS}; do \
		echo "Updating package for $${CHART}" ; \
		helm dep update $${CHART} || exit $?; \
		helm package $${CHART} --destination docs || exit $?; \
	done ; \
    cd docs && helm repo index . ;


package: clean-package create-temp-package create-vsphere-manifest combine-crds create-packages archive-package

create-temp-package:
	mkdir -p ${TEMP_PACKAGE}/scripts ${TEMP_PACKAGE}/yaml

combine-crds:
	cat */crds/*.yaml > ${TEMP_PACKAGE}/yaml/objectscale-crd.yaml

create-packages:
	./scripts/scripts_pkg.sh ${SERVICE_ID}

create-vsphere-manifest: create-temp-package
	helm template vsphere-plugin ./objectscale-vsphere -n ${NAMESPACE} \
	--set global.platform=VMware \
	--set global.watchAllNamespaces=${WATCH_ALL_NAMESPACES} \
	--set graphql.enabled=true \
	--set global.registry=${REGISTRY} \
	--set global.registrySecret=${REGISTRYSECRET} \
	--set global.rsyslog_client_stdout_enabled=${ENABLE_STDOUT_LOGS_COLLECTION} \
	--set global.storageClassName=${STORAGECLASSNAME} \
	--set global.secondaryStorageClass=${STORAGECLASSNAME_VSAN_SNA}	${HELM_UI_ARGS} ${HELM_GRAPHQL_ARGS} ${HELM_INSTALLER_ARGS} ${HELM_MANAGER_ARGS} ${HELM_MONITORING_ARGS} ${HELM_DECKS_ARGS} ${HELM_KAHM_ARGS} \
	-f objectscale-vsphere/values.yaml > ${TEMP_PACKAGE}/yaml/${OBJS_VSPHERE_MANIFEST}

archive-package:
	tar -zcvf ${PACKAGE_NAME} ${TEMP_PACKAGE}/*

clean-package:
	rm -rf temp_package ${PACKAGE_NAME}

combine-crd-manager-ci: create-temp-package
	cp -R objectscale-manager/crds ${TEMP_PACKAGE}
	cp -R atlas-operator/crds ${TEMP_PACKAGE}
	cp -R zookeeper-operator/crds ${TEMP_PACKAGE}
	cp -R statefuldaemonset-operator/crds ${TEMP_PACKAGE}
	cp -R influxdb-operator/crds ${TEMP_PACKAGE}
	cat ${TEMP_PACKAGE}/crds/*.yaml > ${TEMP_PACKAGE}/yaml/manager-crd.yaml
	rm -rf ${TEMP_PACKAGE}/crds

create-manager-manifest-ci: create-temp-package
	helm template objectscale-manager ./objectscale-manager -n ${NAMESPACE} \
	--set global.platform=Default --set global.watchAllNamespaces=${WATCH_ALL_NAMESPACES} \
	--set global.registry=${REGISTRY} \
	--set global.registrySecret=${REGISTRYSECRET} \
	--set global.storageClassName=${STORAGECLASSNAME} \
	--set logReceiver.create=false \
	-f objectscale-manager/values.yaml >> ${TEMP_PACKAGE}/yaml/${MANAGER_MANIFEST}

build-installer:
	echo "Setting up install-controller container and building image"
	docker build ${DOCKER_LABELS} --network host -t asdrepo.isus.emc.com:8099/install-controller:${FULL_PACKAGE_VERSION}-$(GIT_COMMIT_COUNT).$(GIT_COMMIT_SHORT_ID) -f ./Dockerfile .
	docker push asdrepo.isus.emc.com:8099/install-controller:${FULL_PACKAGE_VERSION}-$(GIT_COMMIT_COUNT).$(GIT_COMMIT_SHORT_ID)

tag-push-installer:
	docker tag asdrepo.isus.emc.com:8099/install-controller:${FULL_PACKAGE_VERSION}-$(GIT_COMMIT_COUNT).$(GIT_COMMIT_SHORT_ID) asdrepo.isus.emc.com:8099/install-controller:${FULL_PACKAGE_VERSION}
	docker push asdrepo.isus.emc.com:8099/install-controller:${FULL_PACKAGE_VERSION}

generate-issues-events-all:
	mkdir -p ${TEMP_PACKAGE}/yaml

	echo -n > ${ISSUE_EVENTS_RAW}

	for chart in ${FLEXCHARTS}; do  \
		chart_file=$$chart-${FLEXVER}.tgz ; \
		echo "Templating chart $${chart_file}" ;  \
		helm template $$chart docs/$${chart_file} \
			--set product=objectscale --set global.product=objectscale \
			>> ${ISSUE_EVENTS_RAW} ; \
	done ;

	for chart in ${DECKSCHARTS}; do  \
		chart_file=$$chart-${DECKSVER}.tgz ; \
		echo "Templating chart $${chart_file}" ;  \
		helm template $$chart docs/$${chart_file} \
			--set product=objectscale --set global.product=objectscale \
                        --set accessKey=0 --set pin=0 \
                        --set productVersion=0 --set siteID=0 \
			>> ${ISSUE_EVENTS_RAW} ; \
	done ;

	python tools/issues_events_report/issues_events_reporter.py \
		-i ${ISSUE_EVENTS_RAW} -o ${ISSUE_EVENTS_REPORT} -fv ${FLEXVER} -dv ${DECKSVER}
