##########
# OUTPUT
##########

output "instance_public_ip" {
    value = aws_eip.eip.public_ip
}

output "worker_asg_name" {
    value = module.eks.workers_asg_names
}

output "hcl" {
    value = "${yamldecode(file("pod.yaml"))}"
}

output "rendered" {
    value = "${data.template_file.deployment.rendered}"
}

data "template_file" "deployment" {
    template = "${file("pod.yaml")}"

    vars {
        replicas = 3
    }
}
