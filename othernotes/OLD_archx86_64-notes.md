# Start 
### USB-arch-iso tools ==> regular empty USB config for arch  
why? cus, arch-iso cant be modified from within itself to increase root partition.    
### airootfs is essentailly an entire os running in ram, adjust root size cow-space with 'e' at menu...     
loadkeys uk  
sudo nano -w /etc/resolv.conf ==> nameserver ((dns-server))   
iwctl station wlan0 connect SSID   
ping google.com  
timedatectl set-timezone "Europe/London"       
sudo nano /etc/pacman.d/mirrorlist ### use uk mirrors remove others, ((speedy=Ctrl+K))  
lsblk     
sudo gdisk /dev/sdX     
##### EF02 BIOS BOOT NOT SUPPORTED ON MY DEVICES USE EFI EF00     
overwrite with new gpt table ==> o ==> yes  
new partition ==> n  ==> (accept default start) ==> +512M ==> EF00  
n  ==> (accept all defaults, start, end, 8300)  
write ==> w ==> yes  
#####    
sudo mkfs.fat -F32 /dev/sdX1  
sudo mkfs.ext4 /dev/sdX2  
### remember below airootfs fstab is temporary  
sudo nano /etc/fstab    
/dev/sdX2 /mnt/arch ext4 defaults 0 1  
/dev/sdX1 /mnt/arch/boot/efi vfat defaults 0 2 
###   
sudo mkdir -p /mnt/arch/boot/efi     
sudo pacman-key --init   
sudo pacman-key --populate archlinux             
sudo mount -a     
### Need soc-firmaware on msi katana, using latest linux kernel vs lts...                    
sudo pacstrap -K /mnt/arch  
    base  
    linux  
    linux-firmware  
    linux-headers  
    base-devel  
    wireless_tools  
    wpa_supplicant  
    netctl  
    nano  
    dhcpcd  
    networkmanager  
    grub  
    efibootmgr  
    iw  
    reflector  
    xorg  
    sddm  
    plasma  
    alsa-utils  
    alsa-firmware  
    alsa-lib  
    alsa-oss  
    sof-firmware  
    ffmpeg  
    nvidia  
    nvidia-utils  
    nvidia-settings  
    vulkan-tools  
    vulkan-icd-loader  
    intel-ucode  
    mesa  
    git  
    curl  
    firefox  
    konsole  
    dolphin  
    kde-applications  

  
sudo arch-chroot /mnt/arch   
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime  
hwclock --systohc  
echo archx8664-usb > /etc/hostname    
nano -w /etc/locale.gen  # Uncomment the desired locale(s) ((en_GB.UTF-8 UTF-8))   
locale-gen  
echo LANG=en_GB.UTF-8 > /etc/locale.conf      
### Order is important in fstab     
blkid -s UUID -o value /dev/sdX2 | tee -a /etc/fstab    
blkid -s UUID -o value /dev/sdX1 | tee -a /etc/fstab
###    
nano /etc/fstab        
UUID=XXX / ext4 defaults 0 1   
UUID=XXX /boot/efi vfat defaults 0 2
###      
nano /etc/hosts
###  
127.0.0.1	localhost  
::1		localhost  
127.0.1.1	archx8664-usb  
###  
passwd   
useradd -m jabl3s  
passwd jabl3s    
usermod -aG wheel jabl3s  ### remove these at some point... ,audio,video,storage  
EDITOR=nano visudo  
### uncoment the wheel line  
%wheel ALL=(ALL:ALL) ALL
###    
systemctl enable NetworkManager sddm systemd-timesyncd   
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB  
nano /etc/default/grub
###  
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"  
###  
grub-mkconfig -o /boot/grub/grub.cfg    
nano /etc/mkinitcpio.conf
###  
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)  
###  
mkinitcpio -P  
exit   
sudo umount -a   
sudo reboot     
  
  
# END  
### Additional non-sense    
##########  
pamixer --get-volume-human  
$ alsamixer
$ amixer sset Master unmute
$ amixer sset Speaker unmute
$ amixer sset Headphone unmute
  
### Additional commands  
sudo mount -o remount,rw / /  ((REdoesDNS))   
sudo chmod -R o-w /  
pacman -Rns package_name  
blkid   
iwctl device wlan0 set-property Powered on   
iwctl    
device wlan0 set-property Powered on   
station wlan0 scan   
station wlan0 get-networks   
station wlan0 connect SSID   
quit     
sudo systemctl restart systemd-networkd   
/dev/sdX1 /mnt/arch/boot/efi vfat defaults 0 2   
/dev/sdX2 none swap sw 0 0   
/dev/sdX3 /mnt/arch ext4 defaults 0 1      
###  BOOT INTO GRUB identify root       
ls   
ls (hdX,Y)/   
set root=(hdX,Y)   
linux /boot/vmlinuz-<kernel-version> root=/dev/sdXY   ==> uname -r ==> 6.4.12-arch1-1  
initrd /boot/initrd-<initrd-version>   ==> pacman -Qi mkinitcpio ==> 36-1

boot   
#####     
sudo parted /dev/sdX     
mklabel gpt ###USE gdisk to check this still isnt mbr   
mkpart primary fat32 1MiB 512MiB   
set 1 esp on   
mkpart primary linux-swap 512MiB 2GiB   
set 2 swap on   
mkpart primary ext4 2GiB 100%   
quit  
###   
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress   
###  NO SWAP NEEDED  
- Type n to create another new partition for the swap.    
Again, accept the default partition number and first sector.    
Specify the size of your swap partition (e.g., +4G for a 4GB swap partition).   
For the hex code or GUID, use 8200 to set the partition type to "Linux swap."  
sudo mkswap /dev/sdX2  
#########
sudo blkid -s UUID -o value /dev/sdX2 | sudo tee -a /etc/grub.d/40_custom
sudo nano /etc/grub.d/40_custom 
###  
menuentry "JBOOT" {  
    set root=(hd0,gpt2)  
    linux (hd0,gpt1)/vmlinuz-linux root=UUID=theuuidgoesere  
    initrd (hd0,gpt1)/boot/initramfs-linux.img  
}  
###    
  
--recheck /dev/sdX 

### GRUB CONSOLE
  
set root=(hd0,gpt2)  
linux (hd0,gpt1)/vmlinuz-linux root=/dev/sda2  
initrd (hd0,gpt1)/initramfs-linux.img  
  
boot  
###  
grub-install --target=x86_64-pc --recheck /dev/sdX
sudo mkfs.fat -F32 /dev/sdX1 
/dev/sdX1 /mnt/arch/boot vfat umask=0077 0 2   ###grub at /boot efi in arch-chroot /boot/efi
UUID=XXX /boot/efi vfat defaults 0 2 
sudo blkid -s UUID -o value /dev/sdX1 | sudo tee -a /etc/fstab  
In gdisk, type o to create a new empty GUID Partition Table (GPT).     
- Type n to create a new partition. When asked for the partition number, just press Enter to accept the default.      
For the first sector, also press Enter to use the default. For the last sector,     
specify the size of your EFI boot partition (e.g., +512M to create a 512MB EFI partition).     
When prompted for the hex code or GUID, type EF00 to set the partition type to "EFI System Partition."   
- Type n once more to create the root partition.    
Accept the default values for partition number, first sector, and last sector.    
This will use the remaining space on the drive for the root partition.   
For the hex code or GUID, you can use the default, which is typically 8300 for a Linux filesystem.   
- Use the p command to print the partition table and verify that everything looks as expected.    
Ensure that the EFI partition is correctly marked as "EFI System Partition" (code EF00),     
and the root partition with the appropriate type (usually 8300 for Linux).   
- Type w to write the partition table changes to the disk. Confirm this action by typing Y.   
- Type q to exit gdisk.   

~/.nvidia-settings-rc  

### nvidia-xconfig DONT RUN instead...  
nano /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
### 
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
###  
nano /usr/share/sddm/scripts/Xsetup
### 
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
###    
nano /etc/default/grub
###
GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1"

see: https://github.com/korvahannu/arch-nvidia-drivers-installation-guide   

MEH y no werk:: reflector -c GB -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist  
MEH so inconsistent dont run:: curl -Ls https://raw.githubusercontent.com/jabl3s/rke1-arm64/main/archpacklist.txt | sudo pacstrap -K /mnt/arch  
nano /etc/vconsole.conf
###  
KEYMAP=en  
### 
