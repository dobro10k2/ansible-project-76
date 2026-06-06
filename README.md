### Hexlet tests and linter status:
[![Actions Status](https://github.com/dobro10k2/ansible-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/ansible-project-76/actions)

# Docker Deployment Infrastructure

This project automates the provisioning of cloud infrastructure and the configuration of a 3-node Docker cluster in Yandex Cloud using **Terraform** and **Ansible**. 

The infrastructure is designed to host the **Redmine** containerized application with an **Nginx** load balancer (secured via automated Let's Encrypt SSL certificates) and a **PostgreSQL** database.

## Live Application
**URL:** [https://hex-infra.ru](https://hex-infra.ru)

## Architecture & Tech Stack

* **Cloud Provider:** Yandex Cloud
* **Infrastructure as Code (IaC):** Terraform (v1.5.0+)
* **Configuration Management:** Ansible (v2.10+) with **Ansible Vault** for secrets management
* **OS:** Ubuntu 22.04 LTS
* **Containerization:** Docker Engine & Docker Compose
* **Application:** Redmine (Ruby on Rails)
* **Database:** PostgreSQL 15
* **Reverse Proxy & SSL:** Nginx + Certbot (Let's Encrypt)
* **DNS:** Automated A-record creation for `hex-infra.ru`

**Nodes Provisioned:**
1. `infra-node`: Hosts the Nginx Load Balancer and the PostgreSQL database.
2. `app-node-1`: Application worker node (Redmine container).
3. `app-node-2`: Application worker node (Redmine container).

## Prerequisites

Before you begin, ensure you have the following installed on your local control machine:
* [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* `make` utility
* SSH key pair generated (default expected path: `~/.ssh/id_ed25519.pub`)

## Setup & Configuration

1. **Clone the repository:**
   ```bash
   git clone <your_repository_url>
   cd <repository_name>
   ```

2. **Configure Terraform Variables:**
   Create a `terraform.tfvars` file inside the `terraform/` directory to store your Yandex Cloud credentials securely (this file is ignored by Git):
   ```hcl
   yc_token     = "your_yandex_oauth_token"
   yc_cloud_id  = "your_cloud_id"
   yc_folder_id = "your_folder_id"
   ```

3. **Configure Ansible Vault Password:**
   Sensitive variables (like database passwords) are encrypted. You must create a `.vault_pass` file inside the `ansible/` directory containing the decryption password:
   ```bash
   echo "your_secure_vault_password" > ansible/.vault_pass
   ```
   *(Note: This file is ignored by Git to prevent secret leaks).*

## Usage (Quick Start)

The project includes a `Makefile` to simplify deployment operations.

### 1. Provision Infrastructure
Initialize Terraform and provision the Virtual Machines, Network, Security Groups, and DNS zone.
```bash
make tf-init
make tf-apply
```
*Note: Upon successful application, Terraform automatically generates the `ansible/inventory.ini` file with the newly assigned IP addresses.*

### 2. Configure Servers
Download the required Ansible Galaxy roles and prepare the nodes (installing Docker and dependencies).
```bash
# Verify SSH connectivity
make ansible-ping

# Install dependencies (geerlingguy.pip, geerlingguy.docker, geerlingguy.nginx)
make install

# Execute the setup phase (installs Docker Engine)
make setup
```

### 3. Manage Secrets (Ansible Vault)
If you need to update the database password or other sensitive variables:
```bash
make vault-edit     # Safely edit encrypted secrets
make vault-encrypt  # Encrypt a newly created vault.yml
make vault-decrypt  # Decrypt the vault.yml for viewing
```

### 4. Deploy Application
Deploy the PostgreSQL database container, generate the `.env` file from the template, start the Redmine application containers, and configure Nginx with SSL.
```bash
make deploy
```

### 5. Teardown
To destroy all created resources and avoid further cloud charges:
```bash
make tf-destroy
```

## Project Structure

```text
.
├── Makefile                # Automation commands
├── README.md               # Project documentation
├── ansible/
│   ├── group_vars/
│   │   ├── all.yml         # Global variables (domain, email, Nginx upstreams)
│   │   └── webservers/
│   │       ├── vars.yml    # App-specific variables (ports, db settings)
│   │       └── vault.yml   # Encrypted secrets (Ansible Vault)
│   ├── templates/          # Jinja2 templates (e.g., .env.j2, Nginx configs)
│   ├── inventory.ini       # Auto-generated dynamic inventory
│   ├── playbook.yml        # Main playbook (uses tags: setup, deploy)
│   └── requirements.yml    # Ansible Galaxy dependencies
└── terraform/
    ├── compute.tf          # VM provisioning (for_each loop)
    ├── dns.tf              # DNS zone and A-record for hex-infra.ru
    ├── inventory.tftpl     # Template for dynamic Ansible inventory
    ├── network.tf          # VPC, Subnets, and Security Groups (HTTP, HTTPS, SSH, ICMP)
    ├── outputs.tf          # Outputs and local_file generator for inventory
    ├── providers.tf        # Yandex provider configuration
    ├── variables.tf        # Variable definitions
    └── versions.tf         # Terraform and provider versions
```
