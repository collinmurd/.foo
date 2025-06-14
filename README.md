# collinmurd.foo

Infra config for some sites

## Setting up a machine
> One day I'll automate this

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