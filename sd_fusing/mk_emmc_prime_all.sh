#
# Copyright (C) 2010 Samsung Electronics Co., Ltd.
#              http://www.samsung.com/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
####################################


####################################
# make partition
#echo "make sd card partition"
#echo "./sd_fdisk $1"
#./sd_fdisk $1
#dd iflag=dsync oflag=dsync if=sd_mbr.dat of=$1
#rm sd_mbr.dat
 
####################################
# format

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
echo "bl2.bin.signed has been generated successfully"

echo "cat E4412_S.bl1.bin.prime, bl2.bin.signed,../u-boot.bin, E4412_tzsw.bin.prime to uboot.bin"
cat E4412_S.bl1.bin.prime bl2.bin.signed ../u-boot.bin E4412_tzsw.bin.prime > uboot.bin
echo "u-boot-emmc-tz.bin successfully made to support TrustZone"
