NAMESPACE_WEBHOOK=mwh
NAMESPACE_APPLICATION=app

.PHONY: helm
helm:
	helm --namespace=$(NAMESPACE_WEBHOOK) install mwh mwh/webhook-instrumentor --values=helm/values.yaml

.PHONY: un-helm
un-helm:
	helm --namespace=$(NAMESPACE_WEBHOOK) delete mwh

.PHONY: instr
instr:
	kubectl apply -f instrumentation/crd-cluster-instrumentation.yaml

.PHONY: un-instr
un-instr:
	kubectl delete -f instrumentation/crd-cluster-instrumentation.yaml

.PHONY: app
app:
	kubectl -n$(NAMESPACE_APPLICATION) apply -f app/d-echoapp.yaml

.PHONY: un-app
un-app:
	kubectl -n$(NAMESPACE_APPLICATION) delete -f app/d-echoapp.yaml

.PHONY: ns-instr
ns-instr:
	kubectl -n$(NAMESPACE_APPLICATION) apply -f instrumentation/crd-instrumentation.yaml

.PHONY: un-ns-instr
un-ns-instr:
	kubectl -n$(NAMESPACE_APPLICATION) delete -f instrumentation/crd-instrumentation.yaml


.PHONY: update-app
update-app:
	kubectl -n$(NAMESPACE_APPLICATION) rollout restart deployment/echoapp

.PHONY: forward
forward:
	kubectl -n$(NAMESPACE_APPLICATION) port-forward service/echoapp 8282:8282

.PHONY: client
client:
	kubectl -n$(NAMESPACE_APPLICATION) apply -f client/d-client.yaml

.PHONY: un-client
un-client:
	kubectl -n$(NAMESPACE_APPLICATION) delete -f client/d-client.yaml

.PHONY: argo
argo:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

.PHONY: un-argo
	kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl delete namespace argocd

.PHONY: argo-forward
argo-forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: argo-app
argo-app:
	argocd app create echoapp --repo https://github.com/chrlic/appd-instrumentation-argo.git --path app --dest-server https://kubernetes.default.svc --dest-namespace $(NAMESPACE_APPLICATION)

