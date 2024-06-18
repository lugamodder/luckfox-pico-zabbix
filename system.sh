#!/bin/bash

ROOTFS_NAME="rootfs-alpine.tar.gz"
DEVICE_NAME="pico-mini-b"

while getopts ":f:d:" opt; do
  case ${opt} in
    f) ROOTFS_NAME="${OPTARG}" ;;
    d) DEVICE_NAME="${OPTARG}" ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done

DEVICE_ID="6"
case $DEVICE_NAME in
  pico-mini-b) DEVICE_ID="6" ;;
  pico-plus) DEVICE_ID="7" ;;
  pico-pro-max) DEVICE_ID="8" ;;
  *)
    echo "Invalid device: ${DEVICE_NAME}."
    exit 1
    ;;
esac
rm -rf sdk/output/image/*
rm -rf sdk/sysdrv/custom_rootfs/
mkdir -p sdk/sysdrv/custom_rootfs/
cp "$ROOTFS_NAME" sdk/sysdrv/custom_rootfs/

pushd sdk || exit

pushd tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/ || exit
source env_install_toolchain.sh
popd || exit

rm -rf .BoardConfig.mk
echo "$DEVICE_ID" | ./build.sh lunch
echo "export RK_CUSTOM_ROOTFS=../sysdrv/custom_rootfs/$ROOTFS_NAME" >> .BoardConfig.mk

# build sysdrv - rootfs
./build.sh uboot
./build.sh kernel
./build.sh driver
./build.sh env
#./build.sh app
# package firmware
./build.sh firmware
./build.sh save

popd || exit

rm -rf output
mkdir -p output
cp sdk/output/image/update.img "output/$DEVICE_NAME-sysupgrade.img"

mkdir -p output/$DEVICE_NAME
ls -l sdk/output/image/

#cp sdk/output/image/boot.img "output/$DEVICE_NAME/boot.img"
#cp sdk/output/image/download.bin "output/$DEVICE_NAME/download.bin"
#cp sdk/output/image/env.img "output/$DEVICE_NAME/env.img"
#cp sdk/output/image/.env.txt "output/$DEVICE_NAME/.env.txt"
#cp sdk/output/image/idblock.img "output/$DEVICE_NAME/idblock.img"
#cp sdk/output/image/uboot.img "output/$DEVICE_NAME/uboot.img"
#cp sdk/output/image/rootfs.img "output/$DEVICE_NAME/rootfs.img"
#cp sdk/output/image/sd_update.txt "output/$DEVICE_NAME/sd_update.txt"
#cp sdk/output/image/tftp_update.txt "output/$DEVICE_NAME/tftp_update.txt"

cp sdk/output/image/* "output/$DEVICE_NAME/"
tar -czvf "output/$DEVICE_NAME-firmware.tar.gz" output/"$DEVICE_NAME"/
