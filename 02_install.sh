fdisk -l
echo "Enter the disk : "
read disk
echo "Create a Password : "
passwd
read -p "Enter the User Name : " user
sed -i -e 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
useradd -m -G wheel -s /bin/bash $user
passwd $user
read -p "Are you in virtual Box : y OR n : " vbox

deepin = "lightdm lightdm-deepin-greeter lightdm-gtk-greeter deepin deepin-extra"
cinnamon = "cinnamon cinnamon-wallpapers cinnamon-sounds gnome-terminal parcellite lightdm lightdm-slick-greeter lightdm-settings"
gnome = "gdm gnome gnome-extra"
kde = "sddm plasma"
read -p "What desktop you want : d = deepin, c = cinnamon, g = gnome, k = kde" desktop

timedatectl set-timezone Africa/Algiers
ln -sf /usr/share/zoneinfo/Africa/Algiers /etc/localtime
hwclock --systohc
nano /etc/locale.gen
locale-gen
locale -a
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf

echo "myhostname" >> /etc/hostname

echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1	myhostname.localdomain	myhostname" >> /etc/hosts

mkinitcpio -P

pacman -Sy
pacman -S sudo xorg xorg-server wpa_supplicant networkmanager wireless_tools grub os-prober intel-ucode amd-ucode --noconfirm
if [ $desktop = 'd' ]; then
    pacman -S $deepin
elif [ $desktop = 'c' ]; then
    pacman -S $cinnamon
elif [ $desktop = 'g' ]; then
    pacman -S $gnome
elif [ $desktop = 'k' ]; then
    pacman -S $kde
fi
os-prober
grub-install $disk
CONFIG_BLK_DEV_INITRD=Y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=Y
CONFIG_MICROCODE_AMD=y
grub-mkconfig -o /boot/grub/grub.cfg
pacman -Sy

if [ $desktop = 'd' ]; then
    sed -i -e 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/g' /etc/lightdm/lightdm.conf
    systemctl enable lightdm.service
elif [ $desktop = 'c' ]; then
    sed -i -e 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
    systemctl enable lightdm.service
elif [ $desktop = 'g' ]; then
    systemctl enable gdm.service
elif [ $desktop = 'k' ]; then
    systemctl enable sddm.service
fi

systemctl enable wpa_supplicant.service
systemctl enable NetworkManager.service

echo "[device]" >> /etc/NetworkManager/NetworkManager.conf
echo "wifi.scan-rand-mac-address=no" >> /etc/NetworkManager/NetworkManager.conf

if [ $vbox = 'y' ]; then
    pacman -S virtualbox-guest-utils
    systemctl enable vboxservice
fi

exit
umount -R /mnt
echo "Instalation Completed."
reboot
