#!/bin/bash
dnf install -y vim git socat

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

# Install Gather from source
git clone https://github.com/openflighthpc/flight-gather /root/flight-gather
cd /root/flight-gather
/opt/flight/bin/bundle install

# Prepare to receive ssh key
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Hunter send & receive SSH key
cat << EOF > /root/send.sh
SERVER="$SERVER"
HUNTER_GROUPS="$HUNTER_GROUPS"
PREFIX="$PREFIX"

if [ ! -z \${HUNTER_GROUPS} ] ; then 
    GROUPS_ARG="--groups \${HUNTER_GROUPS}"
fi

if [ ! -z \${PREFIX} ] ; then
    IDENTITY_ARG="--prefix \${PREFIX}"
fi

/opt/flight/bin/ruby /root/flight-hunter/bin/hunter send -p 8888 -c '/opt/flight/bin/ruby /root/flight-gather/bin/gather show -f' -s \$SERVER \$GROUPS_ARG \$IDENTITY_ARG --auth hunter
socat -u TCP:\$SERVER:1234 STDOUT >> /root/.ssh/authorized_keys
EOF

bash /root/send.sh
