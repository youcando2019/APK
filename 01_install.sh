#!/bin/bash

loadkeys fr-latin1
wifi-menu
timedatectl set-ntp true

#pacman -Sy
#pacman -S pacman-contrib --noconfirm
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
#rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
#pacman -Syu pacman-mirrorlist --noconfirm

fdisk -l
echo "Enter the disk : "
read disk
fdisk $disk
echo "Enter the partition : "
read partition
echo "Enter the swap : "
read swap
mkfs.ext4 $partition
mkswap $swap
swapon $swap

mount $partition /mnt

#cp /iso/mirrorlist /mnt/etc/pacman.d/mirrorlist
#cp /iso/01_install.sh /mnt
#cp /iso/02_install.sh /mnt
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "Server = "http://mirror.metalgamer.eu/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = "http://archlinux.cu.be/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = "http://arch.eckner.net/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = "http://archlinux.vi-di.fr/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = "http://artfiles.org/archlinux.org/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
pacman -Sy pacman-mirrorlist --noconfirm

pacstrap /mnt base linux linux-firmware nano
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
