
# Security Group for EC2 Instances 
resource "aws_security_group" "app_sg" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2026-01-07T14:06:53.485Z"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = ""
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
