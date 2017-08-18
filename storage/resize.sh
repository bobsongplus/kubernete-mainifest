#!/bin/bash
blockDeviceId=$1

if [ "$2" == "xfs" ]; then
  mkdir -p /tenxcloud${blockDeviceId}
  mount ${blockDeviceId} /tenxcloud${blockDeviceId}
  xfs_growfs ${blockDeviceId}
  umount  /tenxcloud/${blockDeviceId}
elif [ "$2" == "reiserfs" ]; then
  resize_reiserfs ${blockDeviceId}
else
  e2fsck -y -f ${blockDeviceId}
  resize2fs ${blockDeviceId}
fi

echo " Resizing done..."
