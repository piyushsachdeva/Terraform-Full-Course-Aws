environment          = "test"
instance_type        = "t2.micro"
desired_capacity     = 2
min_size             = 2
max_size             = 4
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
