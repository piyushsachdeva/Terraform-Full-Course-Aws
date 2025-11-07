# In a real-world scenario, these resources would already exist.
# We are creating them here to simulate that environment.

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "shared" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "shared-network-vpc"
  }
}

resource "aws_subnet" "shared" {
  vpc_id     = aws_vpc.shared.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "shared-primary-subnet"
  }
}
