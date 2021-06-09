resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket = "velocidata-eks-terraform-state"
    object_lock_configuration {
        object_lock_enabled = "Enabled"
    }
    versioning {
        enabled = true
    }  # Enable server-side encryption by default
    server_side_encryption_configuration {
        rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
        }
    }
}