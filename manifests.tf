resource "kubectl_deployment" "test" {
    yaml_body = file("pod.yaml")
}