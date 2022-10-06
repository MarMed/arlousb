#!/bin/bash -eu

function check_variable () {
  local var_name="$1"
  if [ -z "${!var_name+x}" ]
  then
    setup_progress "STOP: Define the variable $var_name like this: export $var_name=value"
    exit 1
  fi
}

function check_udc () {
  local udc
  udc=$(find /sys/class/udc -type l -prune | wc -l)
  if [ "$udc" = "0" ]
  then
    setup_progress "STOP: this device ($(cat /sys/firmware/devicetree/base/model)) does not have a UDC driver"
    exit 1
  fi
}

function check_xfs () {
  setup_progress "Checking XFS support"
  # install XFS tools if needed
  if ! hash mkfs.xfs
  then
    apt-get -y --force-yes install xfsprogs
  fi
  truncate -s 1GB /tmp/xfs.img
  mkfs.xfs -m reflink=1 -f /tmp/xfs.img > /dev/null
  mkdir -p /tmp/xfsmnt
  if ! mount /tmp/xfs.img /tmp/xfsmnt
  then
    setup_progress "STOP: xfs does not support required features"
    exit 1
  fi

  umount /tmp/xfsmnt
  rm -rf /tmp/xfs.img /tmp/xfsmnt
  setup_progress "XFS supported"
}

function check_available_space () {
    if [ -z "$USB_DRIVE" ]
    then
      setup_progress "USB_DRIVE is not set. SD card will be used."
      check_available_space_sd
    else
      if grep -q 'Pi 4' /sys/firmware/devicetree/base/model
      then
        setup_progress "USB_DRIVE is set to $USB_DRIVE. This will be used for /mutable and backingfiles."
        check_available_space_usb
      else
        setup_progress "STOP: USB_DRIVE is supported only on a Pi 4. Set USB_DRIVE to blank or comment it to continue"
        exit 1
      fi
    fi
}

function check_available_space_sd () {
  setup_progress "Verifying that there is sufficient space available on the MicroSD card..."

  # check if backingfiles and mutable already exist
  if [ -e /dev/disk/by-label/backingfiles ] && [ -e /dev/disk/by-label/mutable ]
  then
    backingfiles_size=$(blockdev --getsize64 /dev/disk/by-label/backingfiles)
    if [ "$backingfiles_size" -lt  $(( (1<<30) * 39)) ]
    then
      setup_progress "STOP: Existing backingfiles partition is too small"
      exit 1
    fi
  else
    # The following assumes that all the partitions are at the start
    # of the disk, and that all the free space is at the end.
 
    local available_space
 
    # query unpartitioned space
    available_space=$(sfdisk -F "$BOOT_DISK" | grep -o '[0-9]* bytes' | head -1 | awk '{print $1}')
 
    # Require at least 40 GB of available space.
    if [ "$available_space" -lt  $(( (1<<30) * 40)) ]
    then
      setup_progress "STOP: The MicroSD card is too small: $available_space bytes available."
      setup_progress "$(parted "${BOOT_DISK}" print)"
      exit 1
    fi
  fi

  setup_progress "There is sufficient space available."
}

function check_available_space_usb () {
  setup_progress "Verifying that there is sufficient space available on the USB drive ..."

  # Verify that the disk has been provided and not a partition
  local drive_type
  drive_type=$(lsblk -pno TYPE "$USB_DRIVE" | head -n 1)

  if [ "$drive_type" != "disk" ]
  then
    setup_progress "STOP: The specified drive ($USB_DRIVE) is not a disk (TYPE=$drive_type). Please specify path to the disk."
    exit 1
  fi

  # This verifies only the total size of the USB Drive.
  # All existing partitions on the drive will be erased if backingfiles are to be created or changed.
  # EXISTING DATA ON THE USB_DRIVE WILL BE REMOVED.

  local drive_size
  drive_size=$(blockdev --getsize64 "$USB_DRIVE")

  # Require at least 64GB drive size, or 59 GiB.
  if [ "$drive_size" -lt  $(( (1<<30) * 59)) ]
  then
    setup_progress "STOP: The USB drive is too small: $(( drive_size / 1024 / 1024 / 1024 ))GB available. Expected at least 64GB"
    setup_progress "$(parted "$USB_DRIVE" print)"
    exit 1
  fi

  setup_progress "There is sufficient space available."
}

function check_setup_teslausb () {
  if [ ! -e /root/bin/setup-teslausb ]
  then
    setup_progress "STOP: setup-teslausb is not in /root/bin"
    exit 1
  fi

  local parent
  parent="$(ps -o comm= $PPID)"
  if [ "$parent" != "setup-teslausb" ]
  then
    setup_progress "STOP: $0 must be called from setup-teslausb: $parent"
    exit 1
  fi
}

check_udc

check_xfs

check_setup_teslausb

check_variable "CAM_SIZE"

check_available_space
