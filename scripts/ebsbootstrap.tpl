#!/bin/bash

# Partition Disks
for disk1 in /dev/sdf, /dev/sdg, /dev/sdh, /dev/sdi, /dev/sdj; do
    echo -e "o\nn\np\n1\n\n\nw" | fdisk $disk1
done

# Create Physical Volumes
pvcreate /dev/xvdf1 /dev/xvdg1 /dev/xvdh1 /dev/xvdi1 /dev/xdj1

# Create Volume Group
vgcreate stack_vg /dev/xvdf1 /dev/xvdg1 /dev/xvdh1 /dev/xvdi1 /dev/xdj1

# Create Logical Volumes
lvcreate -L 5G -n Lv_u01 stack_vg
lvcreate -L 5G -n Lv_u02 stack_vg
lvcreate -L 5G -n Lv_u03 stack_vg
lvcreate -L 5G -n Lv_u04 stack_vg
lvcreate -L 5G -n Lv_backup stack_vg

# Format Logical Volumes with ext4
mkfs.ext4 /dev/stack_vg/Lv_u01
mkfs.ext4 /dev/stack_vg/Lv_u02
mkfs.ext4 /dev/stack_vg/Lv_u03
mkfs.ext4 /dev/stack_vg/Lv_u04
mkfs.ext4 /dev/stack_vg/Lv_backup

# Create mount directories
mkdir /u01 /u02 /u03 /u04 /backup

# Mount Logical Volumes
mount /dev/stack_vg/Lv_u01 /u01
mount /dev/stack_vg/Lv_u02 /u02
mount /dev/stack_vg/Lv_u03 /u03
mount /dev/stack_vg/Lv_u04 /u04
mount /dev/stack_vg/Lv_backup /backup
# Automatically mount the volumes after reboot
echo '/dev/stack_vg/Lv_u01 /u01 ext4 defaults 0 0' >> /etc/fstab
echo '/dev/stack_vg/Lv_u02 /u02 ext4 defaults 0 0' >> /etc/fstab
echo '/dev/stack_vg/Lv_u03 /u03 ext4 defaults 0 0' >> /etc/fstab
echo '/dev/stack_vg/Lv_u04 /u04 ext4 defaults 0 0' >> /etc/fstab

# Extend Lv_u01 by 3G
lvextend -L +3G /dev/stack_vg/Lv_u01
resize2fs /dev/stack_vg/Lv_u01
