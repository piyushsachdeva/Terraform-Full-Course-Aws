# Day 07 - Quick Tasks

## What to Do

- [ ] Watch the Day 07 video and take notes
- [ ] Write a short blog with the below tasks

<details>
<summary>Day 7: Terraform Variable Type Constraint Tasks (Click to Expand)</summary>

## Day 7: Terraform Variable Type Constraint Tasks

Below are 10 conceptual tasks, one for each variable type constraint you provided, demonstrating how each type contributes to defining and securing AWS infrastructure.

### Task 1: String Constraint (`environment`, `region`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `environment` | `string` | `"dev"` |
| `region` | `string` | `"us-east-1"` |

**Objective:** Use the simple `string` type variables to set the AWS Provider configuration and apply a basic naming convention.

**Task:** Configure the AWS Provider to utilize the region defined by the `region` variable. Provision an S3 bucket and use the value of the `environment` variable as a mandatory prefix for the bucket name (e.g., `dev-resource-name`).

---

### Task 2: Number Constraint (`instance_count`)

| Variable | Type | Description |
| :--- | :--- | :--- |
| `instance_count` | `number` | "Number of EC2 instances to create" |

**Objective:** Use the `number` constraint to define the desired quantity of a resource using Terraform’s `count` argument.

**Task:** Define a resource block that provisions a variable number of EC2 instances based on the `instance_count` variable. The system must create the exact number of instances specified by this variable.

---

### Task 3: Boolean Constraint (`monitoring_enabled`, `associate_public_ip`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `monitoring_enabled` | `bool` | `true` |
| `associate_public_ip` | `bool` | `true` |

**Objective:** Use `bool` variables to control binary configuration settings (true/false flags) for AWS resources.

**Task:** Provision an EC2 instance. The configuration should reference `monitoring_enabled` to turn on or off the detailed monitoring feature, and `associate_public_ip` to determine whether the instance is configured with a public IP address upon creation.

---

### Task 4: List(string) Constraint (`cidr_block`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `cidr_block` | `list(string)` | `["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]` |

**Objective:** Use a `list(string)` to define multiple, ordered values of the same type for sequential use.

**Task:** Provision an AWS VPC using the first CIDR block from the `cidr_block` list (`10.0.0.0/8`). Subsequently, provision two subnets within that VPC by referencing the second and third items in the list (`192.168.0.0/16` and `172.16.0.0/12`) for their respective subnet CIDR blocks.

---

### Task 5: List(string) Constraint (`allowed_vm_types`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `allowed_vm_types` | `list(string)` | `["t2.micro", "t2.small", "t3.micro", "t3.small"]` |

**Objective:** Use a `list(string)` to enforce internal organizational constraints on allowed resource configuration.

**Task:** Configure an EC2 resource to use the instance type `t2.micro`. Implement a validation check using a `precondition` that ensures the selected instance type is explicitly present within the `allowed_vm_types` list, failing the plan if an unauthorized type is chosen.

---

### Task 6: Set(string) Constraint (`allowed_region`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `allowed_region` | `set(string)` | `["us-east-1", "us-west-2", "eu-west-1"]` |

**Objective:** Use a `set(string)` to define a collection of unique, unordered values, typically for validation purposes.

**Task:** Apply a validation block to the `region` variable (Task 1) using the `contains` function. The validation must confirm that the input region specified by the user is one of the distinct values defined in the `allowed_region` set, thereby preventing deployment to restricted regions.

---

### Task 7: Map(string) Constraint (`tags`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `tags` | `map(string)` | `{Environment = "dev", Name = "dev-Instance", created_by = "terraform"}` |

**Objective:** Use a `map(string)` to pass dynamic key-value pairs, primarily for resource metadata and cost allocation.

**Task:** Provision an AWS resource (such as a VPC). Apply all defined metadata simultaneously by setting the resource's `tags` argument equal to the entire `tags` map variable. Ensure that the resource name derived from the map (`tags["Name"]`) is displayed as an output.

---

### Task 8: Tuple Constraint (`ingress_values`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `ingress_values` | `tuple([ number, string, number ])` | `[ 443, "tcp", 443 ]` |

**Objective:** Use a `tuple` to enforce a rigid structure where the position and type of elements are strictly defined.

**Task:** Provision an AWS Security Group and define a single ingress rule. Extract the required parameters (start port, protocol, end port) for the rule by referencing the elements of the `ingress_values` tuple sequentially.

---

### Task 9: Object Constraint (`config`)

| Variable | Type | Default |
| :--- | :--- | :--- |
| `config` | `object(...)` | `{region = "us-east-1", monitoring = true, instance_count = 1}` |

**Objective:** Use an `object` to group multiple configuration values of different types under a single variable, improving code organization.

**Task:** Use the attributes within the `config` object to drive the deployment:
1. Set the AWS Provider region using the nested `config.region`.
2. Determine the resource count for an EC2 instance using the nested `config.instance_count`.
3. Set the monitoring flag for the instance using the nested `config.monitoring`.

---

### Task 10: Mixed Type Constraints (Overall Deployment Summary)

**Objective:** Combine several variable types (`string`, `number`, `map`) into a single output to summarize the final state of the infrastructure deployment.

**Task:** Create a Terraform output block named `deployment_summary`. This output must display the following three key pieces of information, sourced from their respective variables: the overall `environment` (string), the `instance_count` (number), and the `Name` tag extracted from the `tags` map.

</details>

  - Include your own diagrams and code examples
  - Embed the video
- [ ] Share your blog on LinkedIn and Twitter/X with **#30daysofawsterraform**
- [ ] Tag me (Piyush Sachdeva)
- [ ] Submit your work by creating the issue

## Tips

- Keep it simple and clear, feel free to take AI assistance but do not overuse it
- Use your own diagrams
- Engage with others’ posts

Good luck! 🚀
