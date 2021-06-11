cryptsetup luksOpen /dev/nvme0n1p2 enc-pv
lvchange -a y /dev/vg/swap
lvchange -a y /dev/vg/root
mount /dev/vg/root /mnt
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/vg/swap
