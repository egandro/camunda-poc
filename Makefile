DIR_HASH=$(shell git rev-parse --short HEAD)
CI_REGISTRY=localhost:5001
CI_PROJECT_NAME=service
CI_REGISTRY_IMAGE=$(CI_REGISTRY)/$(CI_PROJECT_NAME)
TAG=$(DIR_HASH)

export KUBECONFIG=.kubeconfig
export KIND_CLUSTER_NAME=signoz-test

all:
	@echo "all"

create-registry:
	./scripts/createregistry.sh

destroy-registry:
	./scripts/destroyregistry.sh

create-cluster: create-registry
	kind create cluster --config=./kind-config.yaml
	./scripts/connectregistry.sh
	kubectl cluster-info --context kind-signoz-test

destroy-cluster: destroy-registry
	kind delete cluster

helm-prepare:
	helm repo add signoz https://charts.signoz.io
	helm repo update

install-signoz: helm-prepare
	kubectl create ns platform
	helm --namespace platform install my-release signoz/signoz -f ./values.yaml
	sleep 30
	@echo waiting until frontend pod is ready... this is sometimes super unstable and needs to be fixed!
	kubectl -n platform wait --for=condition=ready \
      pod -l "app.kubernetes.io/component=frontend" --timeout=30m

uninstall-signoz:
	helm uninstall --namespace platform my-release
	kubectl -n platform patch clickhouseinstallations.clickhouse.altinity.com/my-release-clickhouse -p '{"metadata":{"finalizers":[]}}' --type=merge
	kubectl -n platform delete pvc -l app.kubernetes.io/instance=my-release
	kubectl delete namespace platform

connect-web:
	echo "Visit http://127.0.0.1:3301 to use your application"
	kubectl --namespace platform port-forward `kubectl get pods --namespace platform -l "app.kubernetes.io/name=signoz,app.kubernetes.io/instance=my-release,app.kubernetes.io/component=frontend" -o jsonpath="{.items[0].metadata.name}"` 3301:3301


#
# dummy go application
#
run: build
	deploy/service

build:
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o deploy/service ./cmd

package:
	cd deploy && \
	DOCKER_BUILDKIT=1 docker build  \
		--tag $(CI_REGISTRY_IMAGE):$(TAG) \
		--tag $(CI_REGISTRY_IMAGE):latest .
	@echo created $(CI_REGISTRY_IMAGE):$(TAG)

push:
	docker push $(CI_REGISTRY_IMAGE):$(TAG)

deployment: build package push
	@kubectl create namespace the-app 2>/dev/null || true
	@kubectl -n the-app delete deploy server 2>/dev/null || true
	kubectl -n the-app create deployment server --image=$(CI_REGISTRY_IMAGE):$(TAG)

showlogs:
	kubectl  -n the-app logs -f pods/$$(kubectl -n the-app get pod -l "app=server" -o jsonpath="{.items[0].metadata.name}")
