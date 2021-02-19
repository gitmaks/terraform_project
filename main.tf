provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

# ______________________________________________________________________________

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmp60+GGnRIZJ9pe1F/xo7QGH7qhm23gx8ZAhVBK9Z5ysd7yyeQjMel7ZwmVYym9JWueY2eWhfJBGdnP68c2+EnAjNmZ8fsx7N9mBRYfmKjEh+wMMajZikONGk62q4a9QgrTrZCybErmNPPLdsgHwLulJ23uMWnxpDG4XGUlqMr+E1RlAYddWcpyPRND1TsGH5cy3+91SHUtFmQssTnQrPTntmUMAuFyRyAvAx94Xh0JiZi/4S1FKXwC2WMMgOC4HTQvLrC6zPkYIm9izT6LqEmZu+PxXLU5uiD8ghWyUcQ873RY8Lh3m9aa8tNv0GpOaywvymkE4p4jWnhHbOv+K+U0YLV1lVqg8m4qpPammHKpOg8/43aRDB1xTBGlpVIjTZhi7kqCj7r0DQaPy9A4KizGA7EDINaXsM6u31q+adCEjSzUrycQJutVpKezPkebpZYoMRa+qRnjS5mBH/AiNSuCH+s59GFvglZF7MkW4Nh3nVoLdGDkq/CahY+Rr3rnU="
  tags = {
    Name         = "Jenkins_key"
    ResourceName = "Key_pair"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_security_group" "jenkins_group" {
  name = "jenkins_group"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.access_ip
  }
  dynamic "ingress" {
    for_each = var.port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.access_ip
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name         = "Jenkins_Sec_Group"
    ResourceName = "Security_group"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_launch_configuration" "jenkins_LC" {
  name            = "Jenkins_LC"
  image_id        = "ami-0996d3051b72b5b2c" #default ubuntu ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.jenkins_group.name]
  key_name        = aws_key_pair.jenkins_key.id
  user_data       = file("jenkins.sh")
}
resource "aws_autoscaling_group" "jenkins_autosc_group" {
  name                 = "Jenkins_autosc_group"
  launch_configuration = aws_launch_configuration.jenkins_LC.name
  min_size             = 1
  max_size             = 1
  availability_zones   = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      key                 = "ResourceName"
      value               = "Auto-scaling group"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "Maxim Manovitskiy"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "Jenkins Master auto-scaling group"
      propagate_at_launch = true
    }
  ]
}
