#!/bin/bash

SERVICES="postfix iptables firewalld sendmail "

echo "Disabling services: ${SERVICES}"
systemctl disable ${SERVICES}
systemctl stop  ${SERVICES}

# disable SELINUX:
sed -i 's/^SELINUX=.*$/SELINUX=disabled/'   /etc/selinux/config

