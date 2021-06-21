pipeline{
    agent any
    tools {
        terraform 'terraform-15.4'
    }

    parameters {
        string(name: 'VPC_ID', defaultValue: "vpc-0e97b99574d5e3eb6", description: "ID of the VPC to provision reosurces in.")
        string(name: 'IGW_ID', defaultValue: "igw-080c529ee5e6f258c", description: "ID of the IGW to be used in public subnet routes.")
        choice(name: 'terraform', choices: ['Create', 'Destroy'], description: 'Create or destroy Terraform resources.')
        choice(name: 'region', choices: ['us-east-2', 'us-west-2'], description: 'Region to create resources in.')
        checkboxParameter(name:'provisioned-resources', description: 'Resources to provision using terraform.', format:'JSON', uri:'https://raw.githubusercontent.com/waqaskayani/iac-demo/master/checkbox.json')
    }

    stages {
        stage('Git Checkout'){
            steps{
                git credentialsId: 'waqaskayani', url: 'https://github.com/waqaskayani/iac-demo'
            }
        }
        stage('Hello') {
            steps {
                script {
                    if ( params['provisioned-resources'] == 'eks,rds') {
                        sh"""
                            echo 'Selected EKS and RDS..'
                        """
                    } else if ( params['provisioned-resources'] == 'eks') {
                        sh"""
                            echo 'Selected EKS only..'
                            sed -i 's/^/#/g' rds.tf
                        """
                    } else if ( params['provisioned-resources'] == 'rds') {
                        sh"""
                            echo 'Selected RDS only..'
                            sed -i 's/^/#/g' eks.tf ec2.tf outputs.tf
                        """
                    } else {
                        sh"""
                            echo 'Nothing selected. Aborting the build..'
                        """
                        currentBuild.result = 'ABORTED'
                    } 
                }
            }
        }
        stage('Update Env Variables'){
            steps{
                sh"""
                    sed -i 's@var_eks_vpc_id@\"'"${params.VPC_ID}"'\"@' variables.tf
                    sed -i 's@var_igw_id@\"'"${params.IGW_ID}"'\"@' variables.tf
                    sed -i 's@var_region@\"'"${params.region}"'\"@' variables.tf
                """
                sh 'cat variables.tf'
            }
        }
        stage('Terraform Init'){
            steps{
                sh label: '', script: 'terraform version'
                sh label: '', script: 'terraform init'
            }
        }
        stage('Terraform Apply'){
            when {
                expression { params.terraform == "Create" }
            }
            steps{
                sh "terraform apply --auto-approve"
            }
        }
        stage('Terraform Destroy'){
            when {
                expression { params.terraform == "Destroy" }
            }
            steps{
                sh "terraform destroy --auto-approve"
            }
        }
    }
}