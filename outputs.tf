##########
# OUTPUT
##########

output "instance_public_ip" {
    value = aws_eip.eip[0].public_ip
}

output "worker_asg_name" {
    value = module.eks[0].workers_asg_names
}
