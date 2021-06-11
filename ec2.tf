resource "aws_launch_configuration" "wireguard_lc" {
    name_prefix           = "wireguard-lc"
    image_id              = data.aws_ami.ubuntu.id
    instance_type         = "t2.small"
    iam_instance_profile  = aws_iam_instance_profile.wireguard_instance_profile.name
    key_name              = var.key_name
    enable_monitoring     = false
    ebs_optimized         = false
    security_groups       = [aws_security_group.wireguard_sg.id]
    user_data = <<-EOF
    #!/bin/bash
    apt update -y

    aws ec2 disassociate-address --public-ip $(curl http://169.254.169.254/latest/meta-data/public-ipv4) --region $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
    aws ec2 associate-address --instance-id $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${aws_eip.eip.id} --region $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')

    apt install software-properties-common -y
    add-apt-repository ppa:wireguard/wireguard -y
    apt update
    apt install wireguard-dkms wireguard-tools qrencode -y


    NET_FORWARD="net.ipv4.ip_forward=1"
    sysctl -w  $NET_FORWARD
    sed -i "s:#$NET_FORWARD:$NET_FORWARD:" /etc/sysctl.conf

    cd /etc/wireguard

    umask 077

    SERVER_PRIVKEY=$( wg genkey )
    SERVER_PUBKEY=$( echo $SERVER_PRIVKEY | wg pubkey )

    echo $SERVER_PUBKEY > ./server_public.key
    echo $SERVER_PRIVKEY > ./server_private.key


    curl -s http://169.254.169.254/latest/meta-data/public-ipv4 > ./endpoint.var
    echo ":54321" >> ./endpoint.var

    echo "10.50.0.1" > ./vpn_subnet.var

    echo "8.8.8.8" > ./dns.var

    echo 1 > ./last_used_ip.var

    echo "eth0" > ./wan_interface_name.var

    cat ./endpoint.var | sed -e "s/:/ /" | while read SERVER_EXTERNAL_IP SERVER_EXTERNAL_PORT
    do
    cat > ./wg0.conf.def << CONF
    [Interface]
    Address = $SERVER_IP
    SaveConfig = false
    PrivateKey = $SERVER_PRIVKEY
    ListenPort = $SERVER_EXTERNAL_PORT
    PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $WAN_INTERFACE_NAME -j MASQUERADE;
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $WAN_INTERFACE_NAME -j MASQUERADE;
    CONF
    done

    cp -f ./wg0.conf.def ./wg0.conf
    systemctl enable wg-quick@wg0
    ufw allow 54321/udp

    git clone https://github.com/isystem-io/wireguard-aws.git
EOF
    lifecycle {
        create_before_destroy = true
    }
}

### APP Autoscaling Group ###

resource "aws_autoscaling_group" "wireguard_asg" {
    name                 = "wireguard-asg"
    launch_configuration = aws_launch_configuration.wireguard_lc.name
    min_size             = 1
    max_size             = 1
    desired_capacity     = 1
    health_check_type    = "EC2"
    health_check_grace_period = 240
    vpc_zone_identifier   = module.vpc.public_subnets
    service_linked_role_arn = data.aws_iam_role.aws_service_linked_role.arn

    lifecycle {
        create_before_destroy = true
    }

    tags = concat(
    [
        {
        "key" = "Name"
        "value" = "wireguard-asg"
        "propagate_at_launch" = true
        },
        {
        "key" = "CreatedBy"
        "value" = "Waqas Kayani"
        "propagate_at_launch" = true
        }
    ])
}

resource "aws_eip" "eip" {
    vpc      = true

    tags = {
      "Name" = "wireguard-eip"
      "CreatedBy" = "Waqas Kayani"
    }
}