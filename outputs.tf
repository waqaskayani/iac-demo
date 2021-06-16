##########
# OUTPUT
##########

output "instance_public_ip" {
    value = aws_eip.eip.public_ip
}

output "worker_asg_name" {
    value = module.eks.workers_asg_names
}
