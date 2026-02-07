# Managing Secrets with Ansible Vault

This guide explains how to securely manage credentials in your Ansible playbooks.

## Structure

```
ansible/
└── group_vars/
    └── all/
        ├── vars.yml       # Non-sensitive variables (not encrypted)
        └── vault.yml      # Sensitive credentials (encrypted)
```

## Setup Process

### 1. Edit the vault file with your credentials

```bash
cd ansible
ansible-vault edit group_vars/all/vault.yml
```

It will prompt for a password. Replace the placeholder values:
```yaml
vault_porkbun_api_key: "pk1_abc123..."
vault_porkbun_secret_key: "sk1_xyz789..."
```

### 2. Run playbook with vault password

**Option A: Prompt for password**
```bash
ansible-playbook playbook.yml --ask-vault-pass
```

**Option B: Use password file**
```bash
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore

# Then run with:
ansible-playbook playbook.yml --vault-password-file .vault_pass
```

**Option C: Configure in ansible.cfg (already set up)**
```ini
[defaults]
vault_password_file = .vault_pass
```

Then just run:
```bash
ansible-playbook playbook.yml
```

## Certificate Renewal

The playbook now:
1. Templates the config file with your vault credentials
2. Sets up the cron job
3. **Optionally runs certificate renewal immediately**

To skip immediate renewal:
```bash
ansible-playbook playbook.yml --skip-tags cert_renewal
```

To only run certificate renewal:
```bash
ansible-playbook playbook.yml --tags cert_renewal
```

## Managing the Vault

**View encrypted file:**
```bash
ansible-vault view group_vars/all/vault.yml
```

**Edit encrypted file:**
```bash
ansible-vault edit group_vars/all/vault.yml
```

**Change vault password:**
```bash
ansible-vault rekey group_vars/all/vault.yml
```

**Encrypt existing file:**
```bash
ansible-vault encrypt group_vars/all/vault.yml
```

**Decrypt file (not recommended):**
```bash
ansible-vault decrypt group_vars/all/vault.yml
```

## Git Safety

The vault file is encrypted and safe to commit. However, add your password file to `.gitignore`:

```bash
echo ".vault_pass" >> ../.gitignore
```

## How It Works

1. `group_vars/all/vault.yml` contains encrypted secrets with `vault_` prefix
2. `group_vars/all/vars.yml` references vault variables: `porkbun_api_key: "{{ vault_porkbun_api_key }}"`
3. The Jinja2 template `etc/porkbun_config.json.j2` uses the variables
4. Ansible renders the template and copies it to the server with real credentials
