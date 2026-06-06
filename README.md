### Hexlet tests and linter status:
[![Actions Status](https://github.com/dobro10k2/ansible-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/ansible-project-76/actions)

# Docker Deployment Infrastructure

This project automates the provisioning of cloud infrastructure and the configuration of a 3-node Docker cluster in Yandex Cloud using **Terraform** and **Ansible**. 

The infrastructure is designed to host the **Redmine** containerized application with an **Nginx** load balancer (secured via automated Let's Encrypt SSL certificates), a **PostgreSQL** database, **Redis** for caching, and **Datadog** for monitoring.

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
* **Caching & Queue:** Redis
* **Reverse Proxy & SSL:** Nginx + Certbot (Let's Encrypt)
* **Monitoring:** Datadog (Infrastructure & APM)
* **DNS:** Automated A-record creation for `hex-infra.ru`

**Nodes Provisioned:**
1. `infra-node`: Hosts the Nginx Load Balancer, PostgreSQL database, and Redis service.
2. `app-node-1`: Application worker node (Redmine container + Datadog Agent).
3. `app-node-2`: Application worker node (Redmine container + Datadog Agent).

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
   Sensitive variables (DB passwords, Redis passwords, Datadog API keys) are encrypted. You must create a `.vault_pass` file inside the `ansible/` directory containing the decryption password:
   ```bash
   echo "your_secure_vault_password" > ansible/group_vars/webservers/vault.yml
   ```
   *(Note: This file is ignored by Git to prevent secret leaks).*

## Usage

The project includes a `Makefile` to simplify deployment, linting, and formatting operations.

### 1. Provision Infrastructure
Initialize Terraform and provision the Virtual Machines, Network, Security Groups, and DNS zone.
```bash
make tf-init
make tf-apply
```
*Note: Upon successful application, Terraform automatically generates the `ansible/inventory.ini` file with the newly assigned IP addresses.*

### 2. Code Quality & Linting
Ensure your Infrastructure as Code meets industry standards before deploying.
```bash
# Format and validate Terraform code
make tf-fmt
make tf-lint

# Lint and auto-fix Ansible playbooks
make ansible-lint
make ansible-fix
```

### 3. Configure Servers
Download the required Ansible Galaxy roles and prepare the nodes (installing Docker and core dependencies).
```bash
# Verify SSH connectivity
make ansible-ping

# Install dependencies (pip, docker, nginx, datadog, redis)
make install

# Execute the setup phase (installs Docker Engine)
make setup
```

### 4. Manage Secrets (Ansible Vault)
To securely update passwords or API keys:
```bash
make vault-edit     # Safely edit encrypted secrets
make vault-encrypt  # Encrypt a newly created vault.yml
make vault-decrypt  # Decrypt the vault.yml for viewing
```

### 5. Deploy Application
Deploy infrastructure services (PostgreSQL, Redis), start Redmine containers, configure Nginx with SSL, and initialize Datadog monitoring agents.
```bash
make deploy
```

### 6. Teardown
To destroy all created resources and avoid further cloud charges:
```bash
make tf-destroy
```

## Project Structure

```text
.
├── Makefile                # Automation commands (deploy, lint, format, vault)
├── README.md               # Project documentation
├── ansible/
│   ├── group_vars/
│   │   ├── all.yml         # Global variables (domain, email, Nginx upstreams)
│   │   ├── infra.yml       # Infra node config (Redis bind interface)
│   │   └── webservers/
│   │       ├── vars.yml    # App config (Datadog site, ports, DB/Redis hosts)
│   │       └── vault.yml   # Encrypted secrets (Passwords, API Keys)
│   ├── templates/          # Jinja2 templates (e.g., .env.j2, Nginx config)
│   ├── inventory.ini       # Auto-generated dynamic inventory
│   ├── playbook.yml        # Main playbook (uses tags: setup, deploy)
│   └── requirements.yml    # Ansible Galaxy dependencies
└── terraform/
    ├── compute.tf          # VM provisioning
    ├── dns.tf              # DNS zone and A-record for hex-infra.ru
    ├── inventory.tftpl     # Template for dynamic Ansible inventory
    ├── network.tf          # VPC, Subnets, and Security Groups
    ├── outputs.tf          # Outputs and local_file generator for inventory
    ├── providers.tf        # Yandex provider configuration
    ├── variables.tf        # Variable definitions
    └── versions.tf         # Terraform and provider versions
```
