#!/bin/bash 

sudo su -
yum update -y
yum install git -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
yum install -y nfs-utils
systemctl start httpd
systemctl enable httpd
systemctl is-enabled httpd


#EFS MOUNT
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
sudo echo ${efs}:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4

#ebs creation and mount
EBS_DEVICES="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdg"
#Partitioning Disks
for device in $${EBS_DEVICES}; do
    echo "Partitioning $${device}..."
    echo -e "\np\nn\np\n1\n2048\n16777215\np\nw" | fdisk $${device}
    #checking if newly partitioned disk exists before creating physical volume
    if lsblk $${device}1; then
        pvcreate $${device}1
    else
        echo "Partition $${device}1 does not exist. Retrying..."
        sleep 5
    fi
done
echo "Disk Partitioning Complete!"
#creating volume group with Newly partitioned volumes
pv_part_string="/dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdg1"
vgcreate stack_vg $${pv_part_string}
echo "Volume group successfully created!"
#viewing newly created volume group
vgs
#Creating logical volumes
lv_names="u01 u02 u03 u04 backup"
for name in $${lv_names}; do
    echo "Creating Logical volume Lv_$${name}!"
    lvcreate -L 5G -n Lv_$${name} stack_vg
done
echo "Logical volumes successfully created!"
#formatting Logical volume
volumes="Lv_u01 Lv_u02 Lv_u03 Lv_u04 Lv_backup"
for disk in $${volumes}; do
    echo "Formatting /dev/stack_vg/$${disk} with ext4"
    mkfs.ext4 "/dev/stack_vg/$${disk}"
    echo "$${disk} Successfully formatted"
done
echo "Logical volume formatting successfully completed!"
# Convert space-separated strings to arrays
volume=("Lv_u01" "Lv_u02" "Lv_u03" "Lv_u04" "Lv_backup")
mount=("/u01" "/u02" "/u03" "/u04" "/backup")
# Ensure both arrays have the same length
if [ $${#volume[@]} -ne $${#mount[@]} ]; then
    echo "Volumes and mounts count do not match."
    exit 1
fi
# Iterate over arrays by index
for i in "$${!volume[@]}"; do
    disk=$${volume[$${i}]}
    mount_p=$${mount[$${i}]}
    # Create the mount point
    mkdir -p "$${mount_p}"
    # Mount the logical volume to the mount point
    echo "Mounting /dev/stack_vg/$${disk} to $${mount_p}"
    mount "/dev/stack_vg/$${disk}" "$${mount_p}"
    # Make the mount persistent across boots by adding it to /etc/fstab
    echo "/dev/stack_vg/$${disk} $${mount_p} ext4 defaults 0 2" >> /etc/fstab
done
echo "Mount points created and Disks successfully mounted!"


#CLIXX
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
cd ${MOUNT_POINT}
sudo chmod -R 755 ${MOUNT_POINT}
git clone ${GIT_REPO}
cp -r CliXX_Retail_Repository/* ${MOUNT_POINT}

#variable declaration 
WP_CONFIG=${MOUNT_POINT}/wp-config.php
DB_HOST_NEW=$(echo "${DB_HOST}" | sed 's/':3306'//g')
#Replacing DB Hostname in wp-config.php file to Correct 
sed -i "s/'wordpress-db.cc5iigzknvxd.us-east-1.rds.amazonaws.com'/'$${DB_HOST_NEW}'/g" $WP_CONFIG


##Grant file ownership of /var/www & its contents to apache user
chown -R apache /var/www
##Grant group ownership of /var/www & contents to apache group
chgrp -R apache /var/www

##Change directory permissions of /var/www & its subdir to add group write
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;

##Recursively change file permission of /var/www & subdir to add group write perm
find /var/www -type f -exec sudo chmod 0664 {} \;


##Restart Apache
systemctl restart httpd


##Enable httpd
/sbin/sysctl -w net.ipv4.tcp_keepalive_time=200 net.ipv4.tcp_keepalive_intvl=200 net.ipv4.tcp_keepalive_probes=5

#
mysql -h "$${DB_HOST_NEW}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" <<EOF
UPDATE wp_options SET option_value = '${CLIXX_LB}' WHERE option_value LIKE '%ALB%';
UPDATE wp_options SET option_value = '${CLIXX_LB}' WHERE option_name= 'siteurl';
UPDATE wp_options SET option_value = '${CLIXX_LB}' WHERE option_name='home';
EOF

#####Modify Apache HTTP server config
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

# sleep 10 

# #waiting for the volumes to be attached

