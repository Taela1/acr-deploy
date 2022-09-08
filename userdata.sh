#!/bin/bash

sgdisk /dev/vda -e

lvextend -l 100%FREE /dev/acronis/buffer

systemctl enable target
systemctl start target

mv /etc/iscsi/initiatorname.iscsi /var/tmp/initiatorname.iscsi.backup
echo "InitiatorName=`/sbin/iscsi-iname`" > /etc/iscsi/initiatorname.iscsi

initiatorname=$( cat /etc/iscsi/initiatorname.iscsi |sed 's/^[^\=]\+\=//' )

targetcli /backstores/block/ create buffer /dev/acronis/buffer
targetcli /backstores/block/ create meta /dev/acronis/meta

targetcli /iscsi create iqn.2021-01.com.vstorage:target1
targetcli /iscsi/iqn.2021-01.com.vstorage:target1/tpg1/acls create $initiatorname

targetcli /iscsi/iqn.2021-01.com.vstorage:target1/tpg1/luns create /backstores/block/buffer
targetcli /iscsi/iqn.2021-01.com.vstorage:target1/tpg1/luns create /backstores/block/meta

targetcli saveconfig
