# Camunda POC

- <https://docs.camunda.io/docs/self-managed/platform-deployment/helm-kubernetes/guides/local-kubernetes-cluster/>
- <https://docs.camunda.org/get-started/quick-start/>
- <https://forum.camunda.io/t/camunda-7-js-worker-conversion-to-camunda-8/42493> 7->8
- <https://camunda-community-hub.github.io/camunda-8-sdk-node-js/>
- <https://docs.camunda.io/docs/1.3/apis-tools/go-client/get-started/>

## Modeler

- <https://camunda.com/download/modeler/>


## Call

```bash
curl -H "Content-Type: application/json" -X POST \
    -d '{"variables": {"amount": {"value":555,"type":"integer"}, "item": {"value":"item-xyz"} } }' \
    http://localhost:26500/process-definition/key/payment-retrieval/start

```