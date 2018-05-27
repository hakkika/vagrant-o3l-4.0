#!/bin/sh

setenforce 0
getenforce

sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config

# Fix chrony, change all ol.pool.ntp.org -> rhel.pool.ntp.org
sed -i 's/\.ol\./.rhel./' /etc/chrony.conf
systemctl restart chronyd

localectl set-keymap fi-latin1

# Disable firewall
systemctl stop firewalld
systemctl disable firewalld

yum makecache fast
yum -y update
yum -y install yum-utils unzip bzip2 bind-utils

yum-config-manager --enable ol7_addons
yum-config-manager --enable ol7_openstack40
yum-config-manager --enable ol7_optional_latest
# yum-config-manager --disable ol7_developer ol7_developer_EPEL ol7_preview

# Create BTRFS filesystem for docker
mkfs.btrfs -f -L var-lib-docker /dev/sdb
echo "LABEL=var-lib-docker /var/lib/docker  btrfs  defaults  0 0" >> /etc/fstab
mkdir -p /var/lib/docker
mount /var/lib/docker

# This will install Docker 1.12 and create user kolla
yum -y install openstack-kolla-preinstall

# Copy Bash rc files for the kolla user
cp /etc/skel/.bash* /usr/share/kolla
chown kolla:kolla /usr/share/kolla/.bash*

systemctl status docker.service
docker version
docker info

# Add vagrant user to the docker group
usermod -aG docker vagrant

IPADDR=$(ifconfig ens32 | grep netmask | awk '{ print $2 }')
echo "This VM has ip address ${IPADDR}"
