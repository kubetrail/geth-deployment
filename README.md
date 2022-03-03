# geth-deployment
Deploy `geth` to a k8s cluster in `dev` node running
as an Ethereum single node testnet with proof-of-authority (PoA) consensus

## disclaimer
> The use of this tool does not guarantee security or usability for any
> particular purpose. Please review the code and use at your own risk.

## installation
first download the code, build container image and push
to your container registry.
> please make sure go toolchain and docker are installed
> at relatively newer versions and also update the
> IMG value to point to your registry
```bash
export IMG=docker.io/your-account-name/geth:v1.10.16
make manifests
make docker-build
make docker-push
```
once the container image is available in your registry you can
deploy the `geth` node.

```bash
make deploy
```

The status of k8s resources should appear as follows:
```bash
kubectl --namespace=geth-system get pods,svc,configmaps,secrets,servicemonitors                                                    dusy: Wed Mar  2 21:13:30 2022

NAME                                           READY   STATUS    RESTARTS   AGE
pod/geth-controller-manager-67dcb6867f-xm7sd   1/1     Running   0          91m

NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/geth-geth   NodePort   10.101.141.39   <none>        8545:30007/TCP   91m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      91m

NAME                                         TYPE                                  DATA   AGE
secret/artifact-registry-key                 kubernetes.io/dockerconfigjson        1      91m
secret/default-token-r4zrn                   kubernetes.io/service-account-token   3      91m
secret/geth-controller-manager-token-tnn86   kubernetes.io/service-account-token   3      91m
```

The service is available as `NodePort` and can be accessed by connecting to the
node IP (not cluster-ip).

## interact with the chain
Exec into the pod by running `geth attach` command as shown below:
```bash
kubectl --namespace=geth-system exec -it deployment/geth-controller-manager -- /geth attach /tmp/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.10.16-stable-20356e57/linux-arm64/go1.17.7
coinbase: 0x<address redacted>
at block: 1 (Thu Mar 03 2022 04:21:18 GMT+0000 (UTC))
 datadir: 
 modules: admin:1.0 clique:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

To exit, press ctrl-d or type exit
> 
```

Transfer funds to an address:
```bash
> eth.sendTransaction({from:eth.coinbase, to:"0x--address-redacted--", value: web3.toWei(125, "ether")})
```

## connect via Metamask
Metamask Chrome extension can be configured to connect to this network.
> Note that Metamask smartphone app will not accept http only RPC addresses
> and therefore in such cases only Chrome extensions can be used.
> See more: https://github.com/MetaMask/metamask-mobile/issues/2314#issuecomment-1013680137

Connection parameters:
* RPC: http://<nodeIP>:30007
* ChainID: 1337
* Currency symbol: ETH

At this point the funds transferred above should be visible in the Metamask wallet.

## linux and arm64 users:
First set env. var `PROJECT` to point to Google cloud project ID.
Also make sure you have artiact registry API enabled and a repo called
`services` has been provisioned for container images to reside in it.

`podman` can be used instead of `docker` to build and push multi-arch container
images. First build `amd64` and `arm64` images separately on respective host machines
with these host architectures.
```bash
make podman-build
```

Save/load container images and make sure both `amd64` and `arm64` images are 
present on the same machine for next step to link them togehter in a manifest.

```bash
make podman-push
```

This will push the container images to your registry and link them in a manifest.
