
### 1\. Regex Validation (Email Check)

**Goal:** Ensure the user inputs an email that strictly ends with `@company.com`.

```hcl
variable "employee_email" {
  type        = string
  description = "Enter your corporate email address"
  
  # Default intentionally left invalid to force you to input a value or override it
  default     = "user@gmail.com" 

  validation {
    # regex("...$") checks the end of the string
    # can() ensures Terraform returns false instead of crashing if regex fails
    condition     = can(regex(".*@company\\.com$", var.employee_email))
    error_message = "The email must be a valid corporate email ending in '@company.com'."
  }
}
```

> **How to test this:**
>
>   * Run `terraform plan`. It will fail because the default is `@gmail.com`.
>   * Run `terraform plan -var="employee_email=john@company.com"`. It will succeed.

-----

### 2\. Numeric Functions (Summing Costs)

**Goal:** Take a list of prices and calculate the total.

```hcl
variable "price_list" {
  type    = list(number)
  default = [10.50, 20.00, 5.25, 100.00]
}

locals {
  # The sum() function adds all elements in a list
  total_cost = sum(var.price_list)
}

output "final_invoice_amount" {
  value = "The total cost is $${local.total_cost}" 
  # Note: The double $$ is how we escape the $ symbol in Terraform strings
}
```

-----

### 3\. File Handling (Conditional Logic)

**Goal:** Check if a file named `custom_config.json` exists. If it does, read it; if not, use a default message.

**The Code:**

```hcl
locals {
  config_file_name = "custom_config.json"

  # fileexists checks the path
  # ? is the "If True" block
  # : is the "If False" block
  app_message = fileexists(local.config_file_name) ? file(local.config_file_name) : "Default Config: No file found, using standard settings."
}

output "application_status" {
  value = local.app_message
}
```

> **How to test this:**
>
> 1.  Run `terraform apply` **without** creating the file.
>       * *Result:* "Default Config: No file found..."
> 2.  Create a file named `custom_config.json` in the same folder with the text: `{"mode": "production"}`.
> 3.  Run `terraform apply` again.
>       * *Result:* `{"mode": "production"}`

-----

### Summary of Commands to Run

1.  Save the code above into `main.tf`.
2.  Initialize: `terraform init`
3.  Test failure (Validation): `terraform plan`
4.  Test success: `terraform apply -var="employee_email=admin@company.com"`

