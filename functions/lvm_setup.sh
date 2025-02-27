#!/bin/bash
set -e  # Exit on error

# Helper function to list available disk devices (only disks, not partitions)
list_disks() {
  echo "Available disks:"
  lsblk -d -o NAME,SIZE,MODEL | tail -n +2 | nl -w2 -s'. '
}

# Helper function to map available disk names into an array
map_disks() {
  disks=($(lsblk -d -n -o NAME))
}

# The main function to set up LVM on selected disks
setup_lvm() {
  echo "This script will set up LVM on selected disks."
  echo "WARNING: All data on the selected disks will be erased!"
  echo

  list_disks
  map_disks

  read -p "Enter the numbers of the disks you want to use (separated by space): " -a selections

  selected_devices=()
  for num in "${selections[@]}"; do
    index=$((num - 1))
    if [ "$index" -ge 0 ] && [ "$index" -lt "${#disks[@]}" ]; then
      selected_devices+=("/dev/${disks[$index]}")
    else
      echo "Invalid selection: $num"
      exit 1
    fi
  done

  echo "\nYou have selected the following devices for LVM:"
  for dev in "${selected_devices[@]}"; do
    echo "  $dev"
  done
  echo

  read -p "Would you like to set custom names/options? [Y/n]: " custom_choice
  custom_choice=${custom_choice:-Y}

  VG_NAME="hdd_vg"
  LV_NAME="hdd_lv"
  MOUNT_POINT="/mnt/hdd_storage"
  FS_TYPE="ext4"

  if [[ "$custom_choice" =~ ^[Yy] ]]; then
    read -p "Enter Volume Group name [default: $VG_NAME]: " input
    VG_NAME=${input:-$VG_NAME}
    read -p "Enter Logical Volume name [default: $LV_NAME]: " input
    LV_NAME=${input:-$LV_NAME}
    read -p "Enter Mount Point [default: $MOUNT_POINT]: " input
    MOUNT_POINT=${input:-$MOUNT_POINT}
    echo "Supported filesystems:"
    echo "  1. ext4 (default)"
    echo "  2. xfs"
    read -p "Enter the number for the filesystem type [default: 1]: " fs_choice
    case "$fs_choice" in
      2) FS_TYPE="xfs" ;;
      *) FS_TYPE="ext4" ;;
    esac
  fi

  echo "\nConfiguration:"
  echo "  Selected Devices: ${selected_devices[@]}"
  echo "  Volume Group Name: $VG_NAME"
  echo "  Logical Volume Name: $LV_NAME"
  echo "  Mount Point: $MOUNT_POINT"
  echo "  Filesystem: $FS_TYPE"
  echo

  read -p "Type 'yes' to continue and wipe the selected disks: " confirm
  if [ "$confirm" != "yes" ]; then
    echo "Aborting."
    exit 1
  fi

  for dev in "${selected_devices[@]}"; do
    echo "Wiping all partitions and signatures on $dev"
    sudo wipefs --all --force "$dev"
    sudo sgdisk --zap-all "$dev"
  done

  for dev in "${selected_devices[@]}"; do
    echo "Initializing physical volume on $dev"
    sudo pvcreate "$dev"
  done

  echo "Creating volume group '$VG_NAME'"
  sudo vgcreate "$VG_NAME" "${selected_devices[@]}"

  echo "Creating logical volume '$LV_NAME' in volume group '$VG_NAME'"
  sudo lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME"

  echo "Formatting /dev/$VG_NAME/$LV_NAME as $FS_TYPE"
  if [ "$FS_TYPE" = "xfs" ]; then
    sudo mkfs.xfs /dev/"$VG_NAME"/"$LV_NAME"
  else
    sudo mkfs.ext4 /dev/"$VG_NAME"/"$LV_NAME"
  fi

  echo "Creating mount point at $MOUNT_POINT and mounting the filesystem"
  sudo mkdir -p "$MOUNT_POINT"
  sudo mount /dev/"$VG_NAME"/"$LV_NAME" "$MOUNT_POINT"

  UUID=$(sudo blkid -s UUID -o value /dev/"$VG_NAME"/"$LV_NAME")
  echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" | sudo tee -a /etc/fstab

  echo "LVM setup complete. The logical volume is mounted at $MOUNT_POINT."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  setup_lvm
fi
