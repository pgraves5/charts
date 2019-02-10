HELM_VERSION := v2.12.3
HELM_URL     := https://storage.googleapis.com/kubernetes-helm
HELM_TGZ      = helm-${HELM_VERSION}-linux-amd64.tar.gz
YQ_VERSION   := 2.2.1
YAMLLINT_VERSION := 1.14.0

.PHONY: test build

dep:
	wget -q ${HELM_URL}/${HELM_TGZ}
	tar xzf ${HELM_TGZ} -C /tmp --strip-components=1
	PATH=`pwd`/linux-amd64/:$PATH
	chmod +x /tmp/helm
	helm init --client-only
	helm plugin install https://github.com/lrills/helm-unittest
	export PATH=$PATH:/tmp
	sudo pip install yamllint=="${YAMLLINT_VERSION}"
	sudo pip install yq=="${YQ_VERSION}"

test:
	for CHART in ecs-cluster ecs-flex-operator mongoose zookeeper-operator; do \
		helm lint $$CHART ; \
		helm unittest $$CHART ; \
		yamllint -c .yamllint.yml -s $$CHART/Chart.yaml $$CHART/values.yaml ; \
	done
	yamllint -c .yamllint.yml -s .yamllint.yml .travis.yml

build:
	REINDEX=0
	for CHART in ecs-cluster ecs-flex-operator mongoose zookeeper-operator; do ; \
		CURRENT_VER=$(yq r $$CHART/Chart.yaml version) ; \
		CHK_INDEX=$(yq r docs/index.yaml "entries.$$CHART[*].version" | "\- $$CURRENT_VER") ; \
		ifeq ($$CHK_INDEX,1) ; \
			helm package $$CHART --destination docs ; \
			REINDEX=1 ; \
		endif
	done
	ifeq($$REINDEX,1)
		cd docs && helm repo index .
	endif