# Local values for VPC Peering Demo

locals {
  # Common tags to be applied to all resources
  common_tags = {
    Project     = "VPC-Peering-Demo"
    ManagedBy   = "Terraform"
    Environment = "Demo"
    CreatedDate = timestamp()
  }

  # Primary VPC configuration
  primary_config = {
    region      = var.primary_region
    vpc_cidr    = var.primary_vpc_cidr
    subnet_cidr = var.primary_subnet_cidr
    vpc_name    = "Primary-VPC-${var.primary_region}"
  }

  # Secondary VPC configuration
  secondary_config = {
    region      = var.secondary_region
    vpc_cidr    = var.secondary_vpc_cidr
    subnet_cidr = var.secondary_subnet_cidr
    vpc_name    = "Secondary-VPC-${var.secondary_region}"
  }

  # User data template for Primary instance
  primary_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Primary VPC Instance</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
            .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { color: #0066cc; }
            .info { background: #e7f3ff; padding: 10px; margin: 10px 0; border-left: 4px solid #0066cc; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 Primary VPC Instance - ${var.primary_region}</h1>
            <div class="info">
                <strong>Private IP:</strong> $(hostname -I | awk '{print $1}')
            </div>
            <div class="info">
                <strong>Hostname:</strong> $(hostname)
            </div>
            <div class="info">
                <strong>VPC CIDR:</strong> ${var.primary_vpc_cidr}
            </div>
            <div class="info">
                <strong>Region:</strong> ${var.primary_region}
            </div>
            <p>✅ VPC Peering is active! This instance can communicate with the Secondary VPC.</p>
        </div>
    </body>
    </html>
    HTML
  EOF

  # User data template for Secondary instance
  secondary_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Secondary VPC Instance</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #fff0f5; }
            .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { color: #cc0066; }
            .info { background: #ffe7f3; padding: 10px; margin: 10px 0; border-left: 4px solid #cc0066; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 Secondary VPC Instance - ${var.secondary_region}</h1>
            <div class="info">
                <strong>Private IP:</strong> $(hostname -I | awk '{print $1}')
            </div>
            <div class="info">
                <strong>Hostname:</strong> $(hostname)
            </div>
            <div class="info">
                <strong>VPC CIDR:</strong> ${var.secondary_vpc_cidr}
            </div>
            <div class="info">
                <strong>Region:</strong> ${var.secondary_region}
            </div>
            <p>✅ VPC Peering is active! This instance can communicate with the Primary VPC.</p>
        </div>
    </body>
    </html>
    HTML
  EOF
}
