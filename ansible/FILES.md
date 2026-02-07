# Server File Structure

This directory mirrors the target server's file structure. Files here are copied to the corresponding locations on the server by Ansible.

## Structure

```
ansible/
├── etc/
│   ├── nginx/
│   │   └── nginx.conf          → /etc/nginx/nginx.conf
│   └── porkbun_config.json     → /etc/porkbun_config.json
└── usr/
    └── local/
        └── bin/
            └── porkbun_cert_renewal.sh → /usr/local/bin/porkbun_cert_renewal.sh
```

## How It Works

When you add a file here, the path indicates where it will be deployed:
- `ansible/etc/nginx/nginx.conf` → deployed to `/etc/nginx/nginx.conf`
- `ansible/usr/local/bin/script.sh` → deployed to `/usr/local/bin/script.sh`

## Adding New Files

To deploy a new file to the server:

1. Create it in the mirrored path. For example, to deploy to `/etc/myapp/config.yaml`:
   ```bash
   mkdir -p ansible/etc/myapp
   vim ansible/etc/myapp/config.yaml
   ```

2. Add a copy task in the appropriate role:
   ```yaml
   - name: Copy myapp configuration
     copy:
       src: etc/myapp/config.yaml
       dest: /etc/myapp/config.yaml
       owner: root
       group: root
       mode: '0644'
   ```

3. Run the playbook:
   ```bash
   ansible-playbook playbook.yml
   ```

## Benefits

✅ Clear destination paths - directory structure shows exactly where files go  
✅ Easy to organize - related files grouped by server location  
✅ Simple copy tasks - no complex path navigation needed  
✅ Self-documenting - structure itself is documentation
