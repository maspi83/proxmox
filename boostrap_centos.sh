#!/bin/bash
echo "--- Disable firewalld "
sudo systemctl disable firewalld
sudo systemctl stop firewalld
echo ""
echo "--- Yum update -y "
sudo yum update -y
echo ""
echo "--- Disable SElinux "
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
echo "Add PrxMox SSH pub key"
mkdir /root/.ssh ; chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC57mBqzUJ45lL4t4ZIJGz1tklw91GR3ljT3etUCOQawx8n9ttWdJ7KjJzo0HTYOfKVB2X09kwA5RUBSQDsN5XkaF0YODAf+HXEAgHBZgevk9CmWEvsSYQkQ/7jrS9IqOnHtSSFHllPeJOYKne7AqvB+VTvYnW6DumbDubo+m++PApScUWTREt+QkL8nbI+W9nwMDjVOy7YSxZ/QGQ9hg0MdegWp8ExYrBhglj5k4HXTUF91KejLt+UMSA6PRZLDwCBoq3ffXAJjiJrSdYbIta23yX3tWumH3HPAGytZfH5fDgoPU8zE1fWhWnnzzHCp7kM9EIO7/khGjgr8iBK8zDyGPJx1bufuRlq6A7euA1eyEPcX/ZRaWDPC2n1NKaDRY4UDtAuPSWTXjN1wnXElnznxxtEQhYB29lfGtwY9xPkw4AfoGIidqqnXxKXtBihCBCxBKFZkZxuyV/01/DBPE1s08GsAqe0orzyiTVEUt2BcpqOFXqkrvtrNALZ/ZkqLds= root@prxmox1' >> /root/.ssh/authorized_keys
