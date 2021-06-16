resource "kubectl_manifest" "test" {
    yaml_body = file("pod.yaml")
}