DIR_HASH=$(shell git rev-parse --short HEAD)
CI_REGISTRY=localhost:5001
CI_PROJECT_NAME=service
CI_REGISTRY_IMAGE=$(CI_REGISTRY)/$(CI_PROJECT_NAME)
TAG=$(DIR_HASH)

export KUBECONFIG=.kubeconfig
export KIND_CLUSTER_NAME=camunda-platform-local

all:
	@echo "all"

create-registry:
	./scripts/createregistry.sh

destroy-registry:
	./scripts/destroyregistry.sh

create-cluster: create-registry
	kind create cluster --config=./kind-config.yaml
	./scripts/connectregistry.sh
	kubectl cluster-info --context kind-$(KIND_CLUSTER_NAME)
	docker update --cpus=8 -m 16g --memory-swap -1 $(KIND_CLUSTER_NAME)-control-plane $(KIND_CLUSTER_NAME)-control-plane

destroy-cluster: destroy-registry
	kind delete cluster

helm-prepare:
	helm repo add camunda https://helm.camunda.io
	helm repo update

install-camunda: helm-prepare
	kubectl create ns camunda
	helm --namespace camunda install dev camunda/camunda-platform \
    	-f ./camunda-platform-core-kind-values.yaml

# helm --namespace platform install my-release signoz/signoz -f ./values.yaml
# sleep 30
# @echo waiting until frontend pod is ready... this is sometimes super unstable and needs to be fixed!
# kubectl -n platform wait --for=condition=ready \
#   pod -l "app.kubernetes.io/component=frontend" --timeout=30m

uninstall-camunda:
	helm uninstall --namespace camunda dev

# kubectl -n platform patch clickhouseinstallations.clickhouse.altinity.com/my-release-clickhouse -p '{"metadata":{"finalizers":[]}}' --type=merge
# kubectl -n platform delete pvc -l app.kubernetes.io/instance=my-release
# kubectl delete namespace platform

operate-forward:
	echo "Visit http://127.0.0.1:8081 to use your application"
	kubectl --namespace camunda port-forward svc/dev-operate  8081:80

tasklist-forward:
	echo "Visit http://127.0.0.1:8082 to use your application"
	kubectl --namespace camunda port-forward svc/dev-tasklist  8082:80

connectors-forward:
	echo "Visit http://127.0.0.1:8088 to use your application"
	kubectl --namespace camunda port-forward svc/dev-connectors 8088:8080

zeebe-port:
	kubectl --namespace camunda port-forward svc/dev-zeebe-gateway 26500:26500


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
