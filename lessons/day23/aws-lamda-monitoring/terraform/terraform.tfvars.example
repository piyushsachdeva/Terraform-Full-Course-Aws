# ============================================================================
# TERRAFORM CONFIGURATION EXAMPLE
# Copy this file to terraform.tfvars and customize the values
# ============================================================================

# AWS Region
aws_region = "us-east-1"

# Environment & Project
environment  = "dev"
project_name = "image-processor"

# Lambda Configuration
lambda_runtime     = "python3.12"
lambda_timeout     = 60      # seconds
lambda_memory_size = 1024    # MB
log_level          = "INFO"  # DEBUG, INFO, WARNING, ERROR
log_retention_days = 7       # days

# S3 Configuration
enable_s3_versioning = true

# ============================================================================
# MONITORING & ALERTING
# ============================================================================

# Email address to receive CloudWatch alerts
# NOTE: You MUST confirm the subscription in your email after deployment!
alert_email = "your-email@example.com"

# Optional: SMS alerts for critical issues (format: +1234567890)
# WARNING: SMS alerts may incur additional AWS charges
alert_sms = ""

# CloudWatch Configuration
metric_namespace            = "ImageProcessor/Lambda"
enable_cloudwatch_dashboard = true

# ============================================================================
# ALARM THRESHOLDS
# Configure when alarms should trigger
# ============================================================================

# Error Threshold: Trigger alarm after this many errors
error_threshold = 3

# Duration Threshold: Alert when Lambda execution time exceeds this (ms)
# Recommended: Set to 75% of timeout (e.g., 45000ms for 60s timeout)
duration_threshold_ms = 45000

# Throttle Threshold: Alert when Lambda is throttled this many times
throttle_threshold = 5

# Concurrent Executions: Alert when concurrent executions exceed this
concurrent_executions_threshold = 50

# Log Error Threshold: Alert after this many ERROR logs detected
log_error_threshold = 1

# Enable alarm for no invocations (useful to detect S3 trigger issues)
enable_no_invocation_alarm = false
