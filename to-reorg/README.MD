# LHS Infrastructure - Terraform

This project represents the next evolution of hackspace infrastructure: building it all as code and calling it a day

The current scope is to deploy all required web services onto a k8s cluster with pre-configured config.
Future work is to automate the deployment of a k8s cluster as well

Is currently intended for test deployments on minikube and is NOT production ready

The default main.tf does the following:
- 'lhs_monitoring_deploy' - Installs the `kube-prometheus-stack` helm chart to setup prometheus and grafana for monitoring
- 'lhs_authentik_deploy' - Installs `authentik` an IdP intended to provide single sign on capibilities to the hackspace
- 