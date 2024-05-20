# Infrastructure as Code AKS example

This example uses [Terraform](https://www.terraform.io/) to deploy:

* An AKS Cluster ([Managed Azure Kubernetes service](https://azure.microsoft.com/en-us/products/kubernetes-service))
* [Application gateway ](https://learn.microsoft.com/nb-no/azure/application-gateway/tutorial-ingress-controller-add-on-existing#deploy-a-new-application-gateway) as an ingress controller
* And [LetsEncrypt.org on Application Gateway for AKS clusters](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-letsencrypt-certificate-application-gateway) for SSL
* Prometheus
* Grafana in Aiven
* OpenSearch in Aiven
* Aiven vnet peering (VPC)

## TODO
* [ ] Loki
* [ ] OpenCost
