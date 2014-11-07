#! /bin/bash

## ssh config
mkdir -p /var/run/sshd
sed -i "s@PermitRootLogin without-password@PermitRootLogin yes@" /etc/ssh/sshd_config

# Setting the root password
echo -e "neutre\nneutre" | (passwd root)
