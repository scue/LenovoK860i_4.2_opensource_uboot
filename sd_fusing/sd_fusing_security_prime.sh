#
# Copyright (C) 2010 Samsung Electronics Co., Ltd.
#              http://www.samsung.com/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
####################################
reader_type1="/dev/sdc"
reader_type2="/dev/mmcblk0"

if [ -z $1 ]
then
    echo "usage: ./sd_fusing.sh <SD Reader's device file>"
    exit 0
fi

if [ $1 = $reader_type1 ]
then 
    partition1="$11"
    partition2="$12"
    partition3="$13"
    partition4="$14"

elif [ $1 = $reader_type2 ]
then 
    partition1="$1p1"
    partition2="$1p2"
    partition3="$1p3"
    partition4="$1p4"

else
    echo "Unsupported SD reader"
    exit 0
fi

if [ -b $1 ]
then
    echo "$1 reader is identified."
else
    echo "$1 is NOT identified."
    exit 0
fi

####################################
# make partition
#echo "make sd card partition"
#echo "./sd_fdisk $1"
#./sd_fdisk $1
#dd iflag=dsync oflag=dsync if=sd_mbr.dat of=$1
#rm sd_mbr.dat
 
####################################
# format
#umount $partition1 2> /dev/null
#umount $partition2 2> /dev/null
#umount $partition3 2> /dev/null
#umount $partition4 2> /dev/null

#echo "mkfs.vfat -F 32 $partition1"
#mkfs.vfat -F 32 $partition1

#echo "mkfs.ext2 $partition2"
#mkfs.ext2 $partition2  

#echo "mkfs.ext2 $partition3"
#mkfs.ext2 $partition3  

#echo "mkfs.ext2 $partition4"
#mkfs.ext2 $partition4  

make
echo "make bl2"
./mk_bl2_security
chmod 777 bl2.bin.signed
./codesigner_v21 -v2.1 bl2.bin bl2.bin.signed Exynos4412_V21.prv -STAGE2
./codesigner_v21 -v2.1 bl2.bin.signed Exynos4412_V21.spk -STAGE2_VERIFY
echo "make bl2 signed"
./mkpad
#rm bl2.bin
#rm bl2.bin.signed
echo "bl2.bin.signed has been generated successfully"
####################################
# mount 
#umount /media/sd 2> /dev/null
#mkdir -p /media/sd
#echo "mount -t vfat $partition1 /media/sd"
#mount -t vfat $partition1 /media/sd

####################################
#<BL1 fusing>
signed_bl1_position=1
bl2_position=31
uboot_position=63
tzsw_position=719

echo "BL1 fusing"
dd iflag=dsync oflag=dsync if=E4412_S.bl1.bin.prime of=$1 seek=$signed_bl1_position

####################################
echo "BL2 fusing"
dd iflag=dsync oflag=dsync if=bl2.bin.signed of=$1 seek=$bl2_position 
#<u-boot fusing>

echo "u-boot fusing"
dd iflag=dsync oflag=dsync if=../u-boot.bin of=$1 seek=$uboot_position

#<TrustZone S/W fusing>
echo "TrustZone S/W fusing"
dd iflag=dsync oflag=dsync if=./E4412_tzsw.bin.prime of=$1 seek=$tzsw_position

####################################
#<Message Display>
echo "U-boot image is fused successfully."
echo "Eject SD card and insert it again."
