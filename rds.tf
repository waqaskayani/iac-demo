/* resource "aws_db_subnet_group" "default" {
    name       = "subnet-group"
    subnet_ids = aws_subnet.private_subnets.*.id

    tags = {
        Name = "subnet-group"
    }
}

resource "random_password" "password" {
    length           = 12
    special          = true
    override_special = "-_%"
}

resource "aws_db_instance" "app_db" {
    identifier           = "velocidata-stage-postgres"
    allocated_storage    = 20
    storage_type         = "gp2"
    engine               = "postgres"
    engine_version       = "12.5"
    instance_class       = "db.t2.medium"   # change to db.m6g.large
    name                 = "postgres"
    username             = "postgres"
    password             = random_password.password.result
    publicly_accessible  = false
    multi_az             = false
    skip_final_snapshot  = false
    final_snapshot_identifier = "velocidata-stage-postgres-final-snapshot"
    deletion_protection  = false
    enabled_cloudwatch_logs_exports = ["postgresql","upgrade"]
    auto_minor_version_upgrade = false
    db_subnet_group_name = aws_db_subnet_group.default.id
    vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, module.eks.cluster_security_group_id]

    tags = {
            Name = "velocidata-stage-postgres"
    }
}

resource "aws_ssm_parameter" "VD_DB_PASSWORD" {
    name  = "/Velocidata/APP/DB_PASSWORD"
    type  = "SecureString"
    value = random_password.password.result
    overwrite = true
} */
