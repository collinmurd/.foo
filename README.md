# collinmurd.foo

Infrastructure configuration for collinmurd.foo sites

## Quick Start

### Prerequisites

1. Install Terraform: https://developer.hashicorp.com/terraform/install
2. Install Ansible: `sudo apt install ansible` (or `brew install ansible` on macOS)
3. Configure OCI CLI credentials at `~/.oci/oci_api_key.pem`
4. SSH key pair at `~/.ssh/id_rsa`

### Deployment

#### 1. Provision Infrastructure with Terraform

```bash
cd iac

# Initialize Terraform (first time only)
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply
```

This creates:

- VCN with public/private subnets
- Internet Gateway, NAT Gateway, Service Gateway
- Compute instance with Ubuntu
- Dedicated block volume attached for persistent app data
- Security lists and route tables
- Auto-generated Ansible inventory

#### 2. Configure Server with Ansible

```bash
cd ../ansible

# Set up vault password (first time only)
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Edit encrypted credentials (first time only)
ansible-vault edit group_vars/all/vault.yml
# Add your Porkbun API key and secret

# Run configuration playbook
ansible-playbook playbook.yml
```

This configures:

- System packages (curl, jq, etc.)
- Docker and Docker Compose
- Users (groceries) with SSH keys and docker group
- Persistent app-data mount at /var/lib/app-data
- Firewall rules (ports 80, 443)
- Nginx with SSL configuration
- Certificate renewal cron job
- Runs initial certificate renewal

### Making Changes

**Infrastructure changes** (instance size, networking, etc.):

```bash
cd iac
# Edit .tf files
terraform plan
terraform apply
```

**Configuration changes** (nginx, cron jobs, packages, etc.):

```bash
cd ansible
# Edit roles or files in etc/, usr/
ansible-playbook playbook.yml
```

**Update credentials**:

```bash
cd ansible
ansible-vault edit group_vars/all/vault.yml
ansible-playbook playbook.yml
```

### Skip Certificate Renewal

If you want to skip running certificate renewal during playbook execution:

```bash
ansible-playbook playbook.yml --skip-tags cert_renewal
```

## Architecture

```
Terraform       → Infrastructure (immutable)
  ├── VCN, Subnets, Gateways
  ├── Compute instance
  └── Generates Ansible inventory

Cloud-init      → Bootstrap (one-time)
  └── Python for Ansible

Ansible         → Configuration (mutable)
  ├── Packages & Docker
  ├── Users
  ├── Firewall
  ├── Nginx
  └── Cron jobs

Docker          → Applications (independent)
  └── Deployed via separate CI/CD pipelines
```

## Documentation

- [iac/](iac/) - Terraform infrastructure code
- [ansible/README.md](ansible/README.md) - Ansible playbook documentation
- [ansible/SECRETS.md](ansible/SECRETS.md) - Managing credentials with Ansible Vault
- [ansible/FILES.md](ansible/FILES.md) - File structure conventions

## Manual Setup (Legacy - For Reference)

The following steps were previously done manually but are now automated via Terraform and cloud-init:

#### Docker

```bash
# docker from here https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### firewall

```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
```

#### nginx

```bash
sudo apt install nginx
sudo rm /etc/nginx/sites-enabled/default # delete default site

# copy nginx conf from this repo
sudo cp nginx.conf /etc/nginx/sites-available/collinmurd.foo
sudo chown root:root /etc/nginx/sites-available/collinmurd.foo

# add custom landing page from this repo
sudo cp index.html /usr/share/nginx/html/index.html
sudo chown root:root /usr/share/nginx/html/index.html

# enable
cd /etc/nginx/sites-enabled && sudo ln -s collinmurd.foo /etc/nginx/sites-available/collinmurd.foo
sudo nginx -s reload
```

#### create `groceries` user

```bash
sudo adduser groceries --disabled-password --gecos ""

# add to docker user group (which docker created for us)
sudo usermod -aG docker groceries

# create a key pair
sudo su groceries
ssh-keygen -f /home/groceries/.ssh/id_rsa -N ""
cat /home/groceries/.ssh/id_rsa.pub >> /home/groceries/.ssh/authorized_keys
```

#### create `guillotine` user

```bash
sudo adduser guillotine --disabled-password --gecos ""

# add to docker user group (which docker created for us)
sudo usermod -aG docker guillotine

# create a key pair
sudo su guillotine
ssh-keygen -f /home/guillotine/.ssh/id_rsa -N ""
cat /home/guillotine/.ssh/id_rsa.pub >> /home/guillotine/.ssh/authorized_keys
```

#### Cert renewal

```bash
sudo apt update
sudo apt install -y jq # renewal script is dependent on jq

cp cert_renewal/bin/porkbun_cert_renewal.sh /usr/bin/porkbun_cert_renewal.sh
mkdir /etc/porkbun_cert_renewal
cp cert_renewal/porkbun_config.json /etc/porkbun_cert_renewal/some_domain.json
# update that config file with correct values

crontab -e # and add an entry similar to cert_cron
```
