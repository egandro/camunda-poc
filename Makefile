export KUBECONFIG=.kubeconfig
export KIND_CLUSTER_NAME=camunda-platform-local
export ZEEBE_ADDRESS=localhost:26500

all:
	@echo "all"

create-cluster:
	kind create cluster
	kubectl cluster-info --context kind-$(KIND_CLUSTER_NAME)

destroy-cluster: destroy-registry
	kind delete cluster

helm-prepare:
	helm repo add camunda https://helm.camunda.io
	helm repo update

# helm show values camunda/camunda-platform > values.yaml
install-camunda: helm-prepare
	kubectl create ns camunda
	helm --namespace camunda install dev camunda/camunda-platform \
		-f ./camunda-platform-core-kind-values.yaml
	kubectl -n camunda wait --for=condition=ready \
		pod -l "app=camunda-platform" --timeout=30m
	kubectl -n camunda wait --for=condition=ready \
		pod -l "app=elasticsearch-master" --timeout=30m
	kubectl -n camunda wait --for=condition=ready \
		pod -l "app.kubernetes.io/component=zeebe-gateway" --timeout=30m

logs:
	kubectl --namespace camunda get events --field-selector type!=Normal

uninstall-camunda:
	helm --namespace camunda uninstall  dev
	kubectl -n camunda delete pvc --all
	kubectl delete ns camunda

operate-forward:
	echo "Visit http://127.0.0.1:8081 to use your application"
	kubectl --namespace camunda port-forward svc/dev-operate  8081:80

tasklist-forward:
	echo "Visit http://127.0.0.1:8082 to use your application"
	kubectl --namespace camunda port-forward svc/dev-tasklist  8082:80

connectors-forward:
	echo "Visit http://127.0.0.1:8088 to use your application"
	kubectl --namespace camunda port-forward svc/dev-connectors 8088:8080

zeebe-forward:
	kubectl --namespace camunda port-forward svc/dev-zeebe-gateway 26500:26500

forward-all:
	$(MAKE) operate-forward &
	$(MAKE) tasklist-forward &
	$(MAKE) connectors-forward &
	$(MAKE) zeebe-forward &

stop-forward:
	pkill kubectl -9

deploy-model:
	zbctl --insecure deploy models/credit-card.bpmn

start-worker-js:
	cd runner-js && npm install
	node runner-js/worker.js

build-go-worker:
	$(MAKE) -C runner-go build

start-worker-go: build-go-worker
	./runner-go/worker

create-instance:
	zbctl --insecure create instance Process_CreditCard --variables '{ "foo": "bar", "whatever": true, "something": -17 }'
