resource "kubectl_manifest" "terraform_deployment" {
    yaml_body =  file("deployment.yaml")
}

/* 
resource "kubectl_manifest" "service" {
    yaml_body = file("service.yaml")
} */
