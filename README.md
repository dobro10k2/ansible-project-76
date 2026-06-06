### Hexlet tests and linter status:
[![Actions Status](https://github.com/dobro10k2/ansible-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/ansible-project-76/actions)

# Docker Deployment Infrastructure

This project automates the provisioning of cloud infrastructure and the configuration of a 3-node Docker cluster in Yandex Cloud using **Terraform** and **Ansible**. 

The infrastructure is designed to host a containerized application with an Nginx load balancer and a PostgreSQL database.

## Architecture & Tech Stack

* **Cloud Provider:** Yandex Cloud
* **Infrastructure as Code (IaC):** Terraform (v1.5.0+)
* **Configuration Management:** Ansible (v2.10+)
* **OS:** Ubuntu 22.04 LTS
* **Containerization:** Docker Engine & Docker Compose
* **DNS:** Automated A-record creation for `hex-infra.ru`

**Nodes Provisioned:**
1. `infra-node`: Designed to host the Nginx Load Balancer and PostgreSQL database.
2. `app-node-1`: Application worker node.
3. `app-node-2`: Application worker node.

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

## Usage (Quick Start)

The project includes a `Makefile` to simplify deployment operations.

### 1. Provision Infrastructure
Initialize Terraform and provision the Virtual Machines, Network, Security Groups, and DNS zone.
```bash
make tf-init
make tf-apply
```
*Note: Upon successful application, Terraform automatically generates the `ansible/inventory.ini` file with the newly assigned public IP addresses.*

### 2. Configure Servers
Download the required Ansible Galaxy roles (for pip and Docker) and run the main playbook to configure the nodes.
```bash
# Verify SSH connectivity
make ansible-ping

# Install dependencies (geerlingguy.pip, geerlingguy.docker)
make install

# Execute the playbook to install Docker on all nodes
make setup
```

### 3. Teardown
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
│   ├── ansible.cfg         # Ansible configuration
│   ├── group_vars/         # Variables for all hosts
│   │   └── all.yml
│   ├── playbook.yml        # Main playbook for Docker setup
│   └── requirements.yml    # Ansible Galaxy dependencies
└── terraform/
    ├── compute.tf          # VM provisioning (for_each loop)
    ├── dns.tf              # DNS zone and A-record for hex-infra.ru
    ├── inventory.tftpl     # Template for dynamic Ansible inventory
    ├── network.tf          # VPC, Subnets, and Security Groups
    ├── outputs.tf          # IP outputs and local_file generator
    ├── providers.tf        # Yandex provider configuration
    ├── variables.tf        # Variable definitions
    └── versions.tf         # Terraform and provider versions
```
