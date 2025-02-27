#!/bin/bash
set -e  # Exit on error

# Helper function to list available disk devices (only disks, not partitions)
list_disks() {
  echo "Available disks:"
  # List disks with their names, sizes, and models (ignores header)
  lsblk -d -o NAME,SIZE,MODEL | tail -n +2 | nl -w2 -s'. '
}

# Helper function to map available disk names into an array
map_disks() {
  # Grab disk names from lsblk output (skipping header)
  disks=($(lsblk -d -n -o NAME))
}

# The main function to set up LVM on selected disks
setup_lvm() {
  echo "This script will set up LVM on selected disks."
  echo "WARNING: All data on the selected disks will be erased!"
  echo

  # List available disks
  list_disks
  map_disks

  # Ask the user to select disks by number (e.g., 1 3 4)
  read -p "Enter the numbers of the disks you want to use (separated by space): " -a selections

  # Build an array of device paths based on user selection
  selected_devices=()
  for num in "${selections[@]}"; do
    # Adjust index: list numbering starts at 1, arrays at 0.
    index=$((num - 1))
    # Validate index
    if [ "$index" -ge 0 ] && [ "$index" -lt "${#disks[@]}" ]; then
      selected_devices+=("/dev/${disks[$index]}")
    else
      echo "Invalid selection: $num"
      exit 1
    fi
  done

  echo
  echo "You have selected the following devices for LVM:"
  for dev in "${selected_devices[@]}"; do
    echo "  $dev"
  done
  echo

  # Ask if user wants to set custom names and options (or use defaults)
  read -p "Would you like to set custom names/options? [Y/n]: " custom_choice
  custom_choice=${custom_choice:-Y}

  # Set default names and values
  VG_NAME="hdd_vg"
  LV_NAME="hdd_lv"
  MOUNT_POINT="/mnt/hdd_storage"
  FS_TYPE="ext4"  # Supported: ext4 (default), xfs

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
      2)
        FS_TYPE="xfs"
        ;;
      *)
        FS_TYPE="ext4"
        ;;
    esac
  fi

  echo
  echo "Configuration:"
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

  # Create physical volumes on each selected disk
  for dev in "${selected_devices[@]}"; do
    echo "Initializing physical volume on $dev"
    sudo pvcreate "$dev"
  done

  # Create a volume group using the selected devices
  echo "Creating volume group '$VG_NAME'"
  sudo vgcreate "$VG_NAME" "${selected_devices[@]}"

  # Create a logical volume that uses 100% of the available space in the VG
  echo "Creating logical volume '$LV_NAME' in volume group '$VG_NAME'"
  sudo lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME"

  # Format the logical volume with the selected filesystem
  echo "Formatting /dev/$VG_NAME/$LV_NAME as $FS_TYPE"
  if [ "$FS_TYPE" = "xfs" ]; then
    sudo mkfs.xfs /dev/"$VG_NAME"/"$LV_NAME"
  else
    sudo mkfs.ext4 /dev/"$VG_NAME"/"$LV_NAME"
  fi

  # Create the mount point and mount the new filesystem
  echo "Creating mount point at $MOUNT_POINT and mounting the filesystem"
  sudo mkdir -p "$MOUNT_POINT"
  sudo mount /dev/"$VG_NAME"/"$LV_NAME" "$MOUNT_POINT"

  # Add the mount to /etc/fstab using its UUID for persistent mounting
  UUID=$(sudo blkid -s UUID -o value /dev/"$VG_NAME"/"$LV_NAME")
  echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" | sudo tee -a /etc/fstab

  echo "LVM setup complete. The logical volume is mounted at $MOUNT_POINT."
}

# If this script is executed directly, call the setup_lvm function.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  setup_lvm
fi
