#!/bin/bash
OUTPUT_DIR="output"
ROOTFS_FILE="rootfs-alpine.tar.gz"

ROOTFS_WORKSPACE_NAME="rootfs-alpine"
ROOTFS_WORKSPACE_FILE="$ROOTFS_WORKSPACE_NAME.ext4"
ROOTFS_WORKSPACE_MNT="/var/tmp/$ROOTFS_WORKSPACE_NAME/"

rootfs_workspace_drop() {
  umount -R "$ROOTFS_WORKSPACE_MNT"
  rm -rf "$ROOTFS_WORKSPACE_FILE" "$ROOTFS_WORKSPACE_MNT"
}
rootfs_workspace_new() {
  mkdir -p "$ROOTFS_WORKSPACE_MNT"
  dd if=/dev/zero of="$ROOTFS_WORKSPACE_FILE" bs=1M count=250
  mkfs.ext4 "$ROOTFS_WORKSPACE_FILE"
  echo "Mount $ROOTFS_WORKSPACE_FILE on $ROOTFS_WORKSPACE_MNT"
  mount "$ROOTFS_WORKSPACE_FILE" "$ROOTFS_WORKSPACE_MNT"
}

# Create and mount rootfs
rootfs_workspace_drop
rootfs_workspace_new
# Setting up multiarch support
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create docker
DOCKER_CONTAINER="arm32v7/alpine:latest"
docker container rm -f armv7alpine

docker run \
    --name armv7alpine \
    --platform linux/arm/v7 \
    --net host \
    --mount type=bind,source=./bootstrap.sh,target=/bootstrap.sh \
    -v "$ROOTFS_WORKSPACE_MNT:/extrootfs" \
    $DOCKER_CONTAINER \
    /bootstrap.sh

# Configuring rootfs and overlay
overlay() {
  local OVERLAY_WORKSPACE="overlay-workspace"
  rm -rf "$OVERLAY_WORKSPACE"
  cp -R --preserve=links overlay "$OVERLAY_WORKSPACE"

  HOSTNAME="luckfox"
  sed -i -e "s/{HOSTNAME}/$HOSTNAME/g" "$OVERLAY_WORKSPACE/etc/hostname"

  TTY_PORT="ttyFIQ0"
  sed -i -e "s/{TTY_PORT}/$TTY_PORT/g" "$OVERLAY_WORKSPACE/etc/securetty"
  sed -i -e "s/{TTY_PORT}/$TTY_PORT/g" "$OVERLAY_WORKSPACE/etc/inittab"

  rsync -aL "$OVERLAY_WORKSPACE/" "$ROOTFS_WORKSPACE_MNT/"
  rm -rf "$OVERLAY_WORKSPACE"

  echo "Include /etc/ssh/sshd_config.d/*.conf" >> \
    "$ROOTFS_WORKSPACE_MNT/etc/ssh/sshd_config"

  #ln -s "/etc/init.d/00_link_mount" \
    #"$ROOTFS_WORKSPACE_MNT/etc/runlevels/default/00_link_mount"

  #ln -s "/etc/init.d/10_usb_gadget" \
  #  "$ROOTFS_WORKSPACE_MNT/etc/runlevels/default/10_usb_gadget"

  ln -s "/etc/init.d/set_permissions" \
    "$ROOTFS_WORKSPACE_MNT/etc/runlevels/default/set_permissions"

  ln -s "/etc/init.d/update_mac" \
    "$ROOTFS_WORKSPACE_MNT/etc/runlevels/default/update_mac"
    
  ln -s "/etc/runlevels/boot/devfs" \
    "$ROOTFS_WORKSPACE_MNT/etc/runlevels/boot/dev"
     
  ln -s "/etc/init.d/devfs" "/etc/init.d/dev"
  
   ln -s "$ROOTFS_WORKSPACE_MNT/run/" "$ROOTFS_WORKSPACE_MNT/var/run/"
  
}

overlay

# Packaging
pushd "$ROOTFS_WORKSPACE_MNT" || exit
tar czf "$ROOTFS_FILE" ./*
popd || exit

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
mv "$ROOTFS_WORKSPACE_MNT/$ROOTFS_FILE" "$OUTPUT_DIR/"

# Cleanup
rootfs_workspace_drop
