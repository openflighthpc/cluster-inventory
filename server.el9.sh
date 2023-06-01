dnf install -y vim git

# Install Ruby
dnf install -y https://repo.openflighthpc.org/openflight/centos/9/x86_64/openflighthpc-release-3-1.noarch.rpm
dnf config-manager --set-enabled openflight-dev
dnf install -y flight-runway

# Install Hunter from source
dnf install -y gcc lsof

git clone https://github.com/openflighthpc/flight-hunter /root/flight-hunter
cd /root/flight-hunter
git checkout develop
/opt/flight/bin/bundle install 

# Configure Hunter 
cat << 'EOF' > /root/flight-hunter/etc/config.yml
port: 8888
auth_key: hunter
EOF

# Run Hunter server
cat << 'EOF' > /usr/lib/systemd/system/flight-hunter.service
[Unit]
Description=Flight Hunter

[Service]
ExecStart=/opt/flight/bin/ruby /root/flight-hunter/bin/hunter hunt

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable flight-hunter --now

# Make hunter easy to use
mkdir -p /root/bin/
cat << 'EOF' > /root/bin/hunter
#!/bin/bash -l

/opt/flight/bin/ruby /root/flight-hunter/bin/hunter $@
EOF
chmod +x /root/bin/hunter

# Share Public Key
ssh-keygen -t rsa -q -f /root/.ssh/id_hunter -N ''
echo "Host *" >> /root/.ssh/config
echo "  IdentityFile /root/.ssh/id_hunter" >> /root/.ssh/config

dnf install -y socat

cat << 'EOF' > /usr/lib/systemd/system/flight-sharepubkey.service
[Unit]
Description=Share Public SSH Key On Port 1234

[Service]
ExecStart=/usr/bin/socat -U TCP4-LISTEN:1234,reuseaddr,fork FILE:"/root/.ssh/id_hunter.pub",rdonly

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flight-sharepubkey --now

