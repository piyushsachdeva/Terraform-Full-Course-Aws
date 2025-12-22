environment          = "production"
instance_type        = "t2.micro" # Or t3.medium for prod
desired_capacity     = 2
min_size             = 2
max_size             = 10
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.11.0/24", "10.2.12.0/24"]
