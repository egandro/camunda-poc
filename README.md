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

## CLI Client

- <https://docs.camunda.io/docs/apis-tools/cli-client/>
- <https://docs.camunda.io/docs/apis-tools/cli-client/cli-get-started/>

```bash
sudo npm i -g zbctl
export ZEEBE_ADDRESS='http://localhost:26500'
# things
export ZEEBE_ADDRESS='[Zeebe API]'
export ZEEBE_CLIENT_ID='[Client ID]'
export ZEEBE_CLIENT_SECRET='[Client Secret]'
export ZEEBE_AUTHORIZATION_SERVER_URL='[OAuth API]'
```

```bash
export ZEEBE_ADDRESS='http://localhost:26500'
zbctl status
zbctl deploy resource foo.bpmn
zbctl create worker test-worker --handler "echo {\"result\":\"Pong\"}"
zbctl create instance camunda-cloud-quick-start-advanced
zbctl create worker test-worker --handler "echo {\"result\":\"...\"}"
#while true; do zbctl create instance camunda-cloud-quick-start-advanced; sleep 1; done
```
