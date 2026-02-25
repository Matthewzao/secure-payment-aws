[🇺🇸 English] | [🇧🇷 Português](./README.pt-br.md)

# 🛡️ Secure Cloud Infrastructure & Private Workload Deployment (Phase 1)

This project documents the implementation of a resilient and secure infrastructure on **Amazon Web Services (AWS)**, fully provisioned as code (**IaC**) using **Terraform**.

Phase 1 establishes a robust foundation based on the **AWS Shared Responsibility Model**, focusing on **attack surface reduction**, **workload isolation**, and **Identity and Access Management (IAM)**.

---

## Design Philosophy
The architecture follows the **Security by Design** principle, where security is the foundation of the network rather than an add-on. To validate the controls, we deploy the **DVWA (Damn Vulnerable Web Application)** within a Docker container.

---

## Technical Architecture — Phase 1

### Networking Layer
* **Segmented VPC:** Total logical isolation of resources.
* **Public Subnet (DMZ):** A transit zone containing only the **Internet Gateway** and **NAT Gateway**. No application computing resources reside here.
* **Private Subnet (Workload):** A restricted layer where the EC2 instance operates.
    * **Zero Public Access:** No public IP address and no inbound route from the internet.
    * **Egress-Only Connectivity:** Controlled outbound access via NAT Gateway exclusively for security patches and container image pulls.

### Compute & Identity (IAM)
* **Workload Hardening:** Mandatory implementation of **IMDSv2** to mitigate credential theft via SSRF (Server-Side Request Forgery) attacks.
* **Zero Trust Admin:** Complete elimination of SSH (port 22), `.pem` keys, and Bastion Hosts. Administration is performed via **AWS Systems Manager (SSM) Session Manager**.
* **Machine Identity:** Use of **IAM Instance Profiles**, eliminating the need for static credentials (Access Keys) within the code or the instance.

---

## Phase 1 Objectives Checklist

- [x] **IaC:** 100% reproducible infrastructure via Terraform.
- [x] **Network Isolation:** Workload hosted in a private subnet with zero inbound exposure.
- [x] **No-SSH Policy:** Administrative access exclusively via SSM (Federated Identity).
- [x] **IMDSv2 Enforcement:** Instance metadata protection.
- [x] **Egress Control:** Outbound traffic managed through a NAT Gateway.
- [x] **Containerized Lab:** Operational DVWA environment in a hardened setting.

---

## Security Decision Matrix (Rationale)

| Control | Technical Decision | Architectural Rationale |
| :--- | :--- | :--- |
| **Admin Access** | **SSM Session Manager** | Removes SSH attack vectors and centralizes full audit trails in CloudWatch. |
| **Exposure** | **Strict Private Subnet** | Minimizes blast radius; the instance IP cannot be scanned from the public internet. |
| **Credentials** | **IAM Instance Profile** | Follows the Principle of Least Privilege (PoLP) without exposing static keys. |
| **Metadata** | **IMDSv2 (Session-based)** | Protects against SSRF, one of the most critical cloud-native vulnerabilities. |
| **Provisioning** | **Terraform** | Ensures immutability and prevents *Configuration Drift* from manual changes. |

---

## Controlled Application Lab (DVWA)

The DVWA application is intentionally vulnerable to validate that:
1. Network isolation prevents direct external exploitation.
2. An application-level compromise does not lead to an infrastructure-level compromise.

## How to Run
Prerequisites: Configured AWS CLI and Terraform v1.0+.

Bash
# Initialize directory and modules
terraform init

# Validate syntax and execution plan
terraform plan

**Internal Validation Commands:**
```bash
# Check container status
sudo docker ps

# Validate service connectivity and response
curl -v localhost # Expected: HTTP 302 Redirect

# Validate controlled outbound path
traceroute google.com # Should resolve via the NAT Gateway IP



