provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "taras_backend_bucket" {
  bucket = "taras-backend-bucket"
}

resource "aws_s3_object" "taras_backend_object" {
  bucket = aws_s3_bucket.taras_backend_bucket.id
  key    = "Dockerrun.aws.json"
  source = "${path.module}/Dockerrun.aws.json"
}

resource "aws_elastic_beanstalk_application" "taras_game_app" {
  name = "taras-game-backend"
}

resource "aws_elastic_beanstalk_application_version" "taras_game_app_version" {
  name        = "taras-game-version"
  application = aws_elastic_beanstalk_application.taras_game_app.name
  bucket      = aws_s3_bucket.taras_backend_bucket.id
  key         = aws_s3_object.taras_backend_object.id
}

resource "aws_elastic_beanstalk_environment" "taras_backend_env" {
  name                   = "taras-game-backend-env"
  application            = aws_elastic_beanstalk_application.taras_game_app.name
  version_label          = aws_elastic_beanstalk_application_version.taras_game_app_version.name
  solution_stack_name    = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  tier                   = "WebServer"
  wait_for_ready_timeout = "6m"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:cloudformation:template:parameter"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "LabInstanceProfile"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.taras_security_group_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.taras_vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.taras_subnet_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.taras_ec2_key_name
  }
}
