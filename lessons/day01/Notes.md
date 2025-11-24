## **Infrastructure as Code (IaC)**

**What is IaC?**
Infrastructure as Code (IaC) is the process of provisioning and managing infrastructure using code, rather than through manual processes or graphical user interfaces (GUIs).

---

## **Tools for IaC**

1. **Terraform**

   * Universal and most popular tool for IaC.
2. **Pulumi**

   * An IaC tool that allows you to use general-purpose programming languages.
3. **Cloud Native IaC (Vendor lock-in tools):**

   * **Azure ARM | Bicep** (Azure)
   * **AWS CloudFormation, AWS CDK, SAM** (AWS)
   * **Deployment Manager, Config Controller / Connector** (GCP)

---

## **Why Write Code if We Have a GUI?**

### **Scenario 1: Simple 3-Tier Application**

* In this scenario, we need to create:

  * Servers, CDN, Route 53, Auto Scaling groups, etc.
* **Time Taken (GUI)**:

  * It may take around **2 hours** to set up manually through the GUI.

### **Scenario 2: Enterprise Architecture with Multiple Environments**

* Multiple environments such as:

  * **Dev**, **Pre-prod**, **Prod**, **DR**, **System Integration Test**, etc.
* **Complexity Increases**:

  * With many environments and configurations, manual provisioning becomes highly inefficient.
* **Time Taken (Manual Provisioning)**:

  * The time and effort required to provision all environments manually become too high.

---

## **Challenges with Manual Provisioning**

1. **Dependency**:

   * Dev teams become dependent on infra teams to provision environments.
2. **Human Errors**:

   * Mistakes in manual processes can lead to unexpected behavior.
3. **"It Works on My Machine"**:

   * The issue where something works on a local machine but not in other environments.
4. **High Costs**:

   * Constantly destroying and rebuilding infrastructure leads to unnecessary costs.
5. **Insecurity**:

   * Manual provisioning can lead to insecure configurations or inconsistent setups.

---

## **Terraform**

**Benefits of Using Terraform:**

* **Provisioning Infrastructure**:
  Terraform allows you to define your infrastructure in code, which can then be deployed in a repeatable manner, saving resources.

* **Maintaining Infrastructure**:
  Terraform enables you to track and manage infrastructure over time, helping ensure security and consistency.

* **Destroying Infrastructure**:
  Terraform provides an easy way to tear down infrastructure, saving costs by avoiding waste.

---

### **Advantages of Terraform**

1. **Write Once, Deploy Many**:

   * Once you write the configuration, it can be reused across different environments.

2. **Version Control**:

   * You can version your infrastructure, which helps with rollback and auditability.

3. **Consistent Environments**:

   * Terraform ensures your environments are consistent and reproducible.

---

## **Terraform Installation on Ubuntu / WSL**

Here’s how I set up Terraform on my machine:

1. **Install HashiCorp's GPG Key and Add Repository:**

   So, I started by adding the HashiCorp GPG key to my system and adding their repository. These steps are needed to get Terraform installed from a trusted source:

   ```bash
   # For Ubuntu/Debian
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

2. **Verify Terraform Installation:**

   After the installation, I ran the following command to check if Terraform was installed correctly:

   ```bash
   terraform -version
   ```

   It worked! I got the Terraform version back, confirming the installation was successful.

---

## **Basic Setup**

To make things a bit easier, I set up a couple of shortcuts:

1. **Alias for Terraform**:
   To avoid typing `terraform` every time, I created an alias:

   ```bash
   alias tf=terraform
   ```

   Now, I just type `tf` to run any Terraform command.

2. **Initialize an Empty Directory**:
   I created a new directory for my Terraform configuration and initialized it:

   ```bash
   tf init
   ```

3. **Enable Auto-Completion**:
   To make the workflow smoother, I installed Terraform auto-completion by running:

   ```bash
   tf -install-autocomplete
   ```

4. **Install the Terraform Extension**:
   Finally, I installed the official Terraform extension from HashiCorp for my IDE (I use VSCode). It provides syntax highlighting, linting, and other features to make working with Terraform more efficient.
