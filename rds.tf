resource "aws_db_subnet_group" "default" {
    name       = "postgres-stage-subnet-group"
    subnet_ids = aws_subnet.private_subnets.*.id

    tags = {
        Name = "postgres-stage-subnet-group"
    }
}


resource "random_password" "password" {
    length           = 12
    special          = true
    override_special = "-_%"
}

resource "aws_db_instance" "app_db" {
    identifier           = "velocidata-stage-postgres"

    ## Storage
    allocated_storage    = 20
    max_allocated_storage = 100
    storage_type         = "gp2"

    ## Database Engine
    engine               = "postgres"
    engine_version       = "12.5"
    instance_class       = "db.m6g.large"   # change to db.m6g.large

    ## Authentication
    name                 = "postgres"
    username             = "postgres"
    password             = random_password.password.result

    ## Network Access
    db_subnet_group_name   = aws_db_subnet_group.default.id
    vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, module.eks.cluster_security_group_id]
    publicly_accessible    = false

    ## High availability
    multi_az             = false

    ## Backup and Restore
    backup_retention_period   = 14
    copy_tags_to_snapshot     = true
    skip_final_snapshot       = false
    final_snapshot_identifier = "velocidata-stage-postgres-final-snapshot-${replace(timestamp(), "/[- TZ:]/", "")}"

    ## Logs
    enabled_cloudwatch_logs_exports = ["postgresql","upgrade"]
    performance_insights_enabled    = true
    monitoring_interval             = 15
    monitoring_role_arn             = aws_iam_role.role_for_rds_enhanced_monitoring.arn

    ## Additional
    maintenance_window         = "Thu:08:04-Thu:08:34"
    deletion_protection        = false  # set to true
    auto_minor_version_upgrade = false

    tags = merge(
        var.additional_tags,
        {
        "Name" = "velocidata-stage-postgres"
        },
    )
}

resource "aws_ssm_parameter" "VD_DB_PASSWORD" {
    name  = "/Velocidata/APP/DB_PASSWORD"
    type  = "SecureString"
    value = random_password.password.result
    overwrite = true
}


##########################
#### Role for RDS instance
##########################
resource "aws_iam_role" "role_for_rds_enhanced_monitoring" {
    name  = "role-for-rds-enhanced-monitoring"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": [
            "monitoring.rds.amazonaws.com"
            ]
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    tags = {
            Name = "role-for-rds-enhanced-monitoring"
        }
}

resource "aws_iam_role_policy_attachment" "rds_policy_attach" {
    role       = aws_iam_role.role_for_rds_enhanced_monitoring.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
