# Using Webhook Instrumentor

## Install the Webhook Instrumentor by Helm

Add Helm repo:

~~~
helm repo add mwh https://cisco-open.github.io/appdynamics-k8s-webhook-instrumentor/
~~~

Update the Help repos:

~~~
helm repo update
~~~

More info at https://developer.cisco.com/codeexchange/github/repo/cisco-open/appdynamics-k8s-webhook-instrumentor/

### Prepare values.yaml for Helm chart

In the `helm` directory, copy file `values-template.yaml` to `values.yaml`.

Replace placeholders by actual values for your controller in the `appdController` section:

~~~
  host: <APPDYNAMICS_CONTROLLER_HOST>
  port: "<APPDYNAMICS_CONTROLLER_PORT>"
  isSecure: true
  accountName: <APPDYNAMICS_CONTROLLER_ACCOUNT_NAME>
  accessKey: "<APPDYNAMICS_CONTROLLER_ACCESS_KEY>"
~~~

### Deploy the Helm chart

Create a namespace for the instrumentor:

~~~
kubectl create namespace <namespace>
~~~

Deploy the chart:

~~~
helm install --namespace=<namespace> <chart-name> mwh/webhook-instrumentor --values=<values-file>
~~~

Check if the instrumentor starts up:

~~~
kubectl -n <namespace> get pods 
~~~

There should be a pod running with a name `webhook-server-*******-****`

## Instrument the Java application

### Configure the instrumentation rules for Java application

Create the instrumentation rules by choosing either cluster-wide instrumentation or namespaced instrumentation rules. Samples are in the `instrumentation` directory. Namespaced rules take precedence before cluster-wide rules.

Cluster-wide instrumentation rules:

~~~
kubectl apply -f instrumentation/crd-cluster-instrumentation.yaml
~~~

Namespaced instrumentation rules:

~~~
kubectl -n <namespace-of-the-app> apply -f instrumentation/crd-instrumentation.yaml
~~~

### Deploy the Java application

Use ArgoCD or deploy manually. Sample application is in the directory `app`. Note the labels defining match between application and instrumentation rules. Label `appd/instr: java` is used in the example. Note the label(s) are specified at the pod template level, not deployment level in the application manifest.

Manually, submit:

~~~
kubectl -napp apply -f app/d-echoapp.yaml
~~~

### Update the instrumentation rules for Java application

If case the instrumentation needs to change, like in case of a new agent version deployment, change the instrumentation rule and update it again, as described in the section *Configure the instrumentation rules for Java application*

### Roll-over the application to pick updated Java instrumentation rules

Roll over the application, either by ArgoCD (Restart the deployment from GUI or CLI) or manually:

~~~
kubectl -napp rollout restart deployment/echoapp
~~~

Verify the deployment and app update status and that the instrumentation change was reflected

## Additional information and examples

https://chrlic.github.io/appd-mwh-blog/
https://chrlic.github.io/appd-mwh-otel-blog/
https://chrlic.github.io/appd-mhw-otel-blog-2/