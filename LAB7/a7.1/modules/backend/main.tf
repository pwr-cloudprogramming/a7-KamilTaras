resource "aws_s3_bucket" "t_back_buckett" {
  bucket = "taras-backend-buckett"
}

resource "aws_s3_object" "back_object" {
  bucket     = aws_s3_bucket.t_back_buckett.id
  key        = "Dockerrun.aws.json"
  source     = "${path.module}/Dockerrun.aws.json"
}

resource "aws_elastic_beanstalk_application" "game" {
  name = "game-back"
}

resource "aws_elastic_beanstalk_application_version" "game_version" {
  name        = "game-version"
  application = aws_elastic_beanstalk_application.game.name
  bucket      = aws_s3_bucket.t_back_buckett.id
  key         = aws_s3_object.back_object.id
}

resource "aws_elastic_beanstalk_environment" "back_env" {
  name                   = "game-back-env"
  application            = aws_elastic_beanstalk_application.game.name
  version_label          = aws_elastic_beanstalk_application_version.game_version.name
  solution_stack_name    = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  tier                   = "WebServer"
  wait_for_ready_timeout = "6m"

  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  
  setting {
    name      = "InstancePort"
    namespace = "aws:cloudformation:template:parameter"
    value     = "80"
  }

  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "LabInstanceProfile"
  }

  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value = var.id_my_security_group
  }

  
  setting {
    name      = "VPCId"
    namespace = "aws:ec2:vpc"
    value     = var.id_my_vpc
  }

  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = var.id_my_subnet
  }
  
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
    resource  = ""
  }
  
  setting {
    name      = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "vockey"
  }

}
