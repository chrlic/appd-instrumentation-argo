

.PHONY: helm
helm:
	helm --namespace=mwh install mwh mwh/webhook-instrumentor --values=helm/values.yaml

.PHONY: un-helm
un-helm:
	helm --namespace=mwh delete mwh

.PHONY: instr
instr:
	kubectl apply -f instrumentation/crd-cluster-instrumentation.yaml

.PHONY: un-instr
un-instr:
	kubectl delete -f instrumentation/crd-cluster-instrumentation.yaml

.PHONY: app
app:
	kubectl -napp apply -f app/d-echoapp.yaml

.PHONY: un-app
un-app:
	kubectl -napp delete -f app/d-echoapp.yaml

.PHONY: ns-instr
ns-instr:
	kubectl -napp apply -f app/crd-instrumentation.yaml

.PHONY: un-ns-instr
un-ns-instr:
	kubectl -napp delete -f app/crd-instrumentation.yaml


.PHONY: update-app
update-app:
	kubectl -napp rollout restart deployment/echoapp

.PHONY: forward
forward:
	kubectl -napp port-forward service/echoapp 8282:8282

.PHONY: client
client:
	kubectl -napp apply -f client/d-client.yaml

.PHONY: un-client
un-client:
	kubectl -napp delete -f client/d-client.yaml

.PHONY: argo
argo:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

.PHONY: un-argo
	kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl delete namespace argocd

.PHONY: argo-forward
forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: argo-app
argo-app:
	argocd app create echoapp --repo https://github.com/chrlic/appd-instrumentation-argo.git --path app --dest-server https://kubernetes.default.svc --dest-namespace app

