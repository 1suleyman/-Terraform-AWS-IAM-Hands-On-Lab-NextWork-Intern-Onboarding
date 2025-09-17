# ⚡ Terraform AWS IAM Hands-On Lab: NextWork Intern Onboarding

In this project, **I’ll use Terraform to onboard a new intern into my AWS environment** while managing access securely. By the end, the intern will have access to **development EC2 instances**, but **not production instances**, all via **Terraform-managed IAM users, groups, policies, and EC2 resources**.

This project is a Terraform-powered version of my hands-on [AWS IAM lab](https://github.com/1suleyman/-AWS-IAM-Hands-On-Lab-NextWork-Intern-Onboarding), fully codified for repeatable deployments.

<img width="1742" height="1346" alt="image" src="https://github.com/user-attachments/assets/e9ac1f12-ea34-4b14-9e2e-d8e686bf880d" />

---

## 🛠️ Project Goals

* Launch **development and production EC2 instances**.
* Create **IAM policy** to restrict intern access to development resources.
* Create **IAM user group** and **intern user**, and assign the policy.
* Create **AWS account alias** for easier login.
* Verify that **permissions are working as intended**.
* Everything is **managed via Terraform** for repeatability and version control.

---

## 📋 Project Structure

```text
terraform-nextwork-intern-lab/
│
├─ [main.tf](./main.tf)          # Terraform core configuration (provider, resources)
├─ [variables.tf](./variables.tf)     # Input variables for instance types, AMI IDs, tags, usernames
├─ [outputs.tf](./outputs.tf)       # Outputs for EC2 IPs, intern login URL, IAM info
├─ [iam-policy.json](./iam-policy.json)  # JSON policy for dev environment
├─ [terraform.tfvars](./terraform.tfvars) # Local values for variables (sensitive info NOT committed)
└─ README.md        # Project documentation
```

---

## 🚀 Step 1: Initialize Terraform

1. Install Terraform if not already: [Terraform Installation](https://developer.hashicorp.com/terraform/downloads)
2. Initialize Terraform in the project directory:

```bash
terraform init
```

This downloads the AWS provider and prepares the backend.

---

## 🖥️ Step 2: Configure AWS Provider

In [`main.tf`](https://github.com/1suleyman/-Terraform-AWS-IAM-Hands-On-Lab-NextWork-Intern-Onboarding/blob/main/terraform-nextwork-intern-lab/main.tf), I specify:

```hcl
provider "aws" {
  region = var.aws_region
}
```

I can override the region in `terraform.tfvars` if needed.

---

## 🖱️ Step 3: Create EC2 Instances

💡 **Important update:** Terraform doesn’t automatically pick a subnet even if your VPC has one. Without specifying `subnet_id`, EC2 creation fails with:

```
MissingInput: No subnets found for the default VPC
```

**Solution:** Use a **data source** to dynamically select a subnet.

```hcl
data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = var.vpc_id
}

resource "aws_instance" "nextwork_dev" {
  ami           = var.dev_ami
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet_ids.vpc_subnets.ids[0]
  tags = {
    Name = "nextwork-dev-${var.owner}"
    Env  = "development"
  }
}
```

✅ **Checkpoint:** Dev and Prod instances are codified with tags and now connect to the correct subnet.

💡 **Tip:** Tags are crucial for **fine-grained IAM permissions** later.

---

## 🛡️ Step 4: IAM Policy

I store the JSON policy in [`iam-policy.json`](https://github.com/1suleyman/-Terraform-AWS-IAM-Hands-On-Lab-NextWork-Intern-Onboarding/blob/main/terraform-nextwork-intern-lab/iam-policy-dev.json) and create it via Terraform.

This policy allows interns to **manage EC2 instances tagged `Env=development`**, but prevents them from touching production.

---

## 👩‍👩‍👧‍👦 Step 5: IAM User Group & User

Terraform creates:

* **IAM user group** for dev environment.
* **Intern user**.
* **Group membership**.
* **Policy attachment**.

✅ **Checkpoint:** Intern user and group created, policy attached.

💡 **Tip:** Terraform allows me to **scale easily** — just add more users to the group without touching the policy.

**Manual Password Management:**

* Terraform **does not store console passwords**.
* Set initial password manually in the AWS Console (IAM → Users → Security credentials → Manage console access).
* Terraform state remains secure — no secrets stored.

---

## 🔗 Step 6: AWS Account Alias

Terraform creates an account alias (`nextwork-interns`) so intern login is easy:

`https://nextwork-interns.signin.aws.amazon.com/console/`

---

## 🧪 Step 7: Outputs

Terraform outputs, in [`outputs.tf`](https://github.com/1suleyman/-Terraform-AWS-IAM-Hands-On-Lab-NextWork-Intern-Onboarding/blob/main/terraform-nextwork-intern-lab/outputs.tf), make testing easy:

* EC2 instance IPs.
* Intern login URL.

✅ **Checkpoint:** Outputs display **EC2 IPs** and **intern login URL**.

---

## 🧹 Step 8: Apply Terraform

```bash
terraform plan
terraform apply
```

💡 **Tip:** Always check the plan to ensure resources will be created as expected.

---

## ✅ Step 9: Test Intern Access

1. Log in using the intern credentials.

<img width="375" height="26" alt="Screenshot 2025-09-16 at 11 55 38" src="https://github.com/user-attachments/assets/f3ae615f-9407-4fcc-a365-cf6634fa23fc" />

3. Verify EC2 access:

* ✅ Can start/stop **development instance**.

<img width="450" height="49" alt="Screenshot 2025-09-16 at 11 56 57" src="https://github.com/user-attachments/assets/addd69e8-a619-4430-a18d-12e912707dfd" />

* ❌ Cannot start/stop **production instance**.

<img width="250" height="70" alt="Screenshot 2025-09-16 at 11 56 20" src="https://github.com/user-attachments/assets/c53d1fd8-8218-484a-8a1e-f58c64cff9d1" />

💡 Always test **both allowed and denied actions** to ensure IAM policy works.

---

## 💡 Notes / Best Practices

* **Resource tagging** = essential for fine-grained IAM control.
* **Groups** simplify permission management.
* **Policies** should be tested to avoid accidental access.
* **Account aliases** make onboarding professional and simple.
* Consider enabling **MFA** for extra security.

---

## 🚀 Optional Extensions

* Add multiple interns via the same group.
* Explore **IAM roles** for cross-account access.
* Learn **AWS Organizations** for multi-account Terraform deployments.
* Add **Auto Scaling** for dev environment.

---

## 📚 References

* [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [AWS IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
* [AWS EC2 Tags](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html)

---

💡 **Pro Tip:** Terraform lets me **repeat this lab safely**, version-control everything, and onboard interns in **minutes instead of hours**.

