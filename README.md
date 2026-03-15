# Arch Linux Base for LiveCD

Base files for creating custom Arch Linux-based distributions.

## Overview

This repository contains the base filesystem structure from Arch Linux bootstrap, designed to be used with **DistroFroger Studio** (or any custom LiveCD builder) to create your own Arch Linux-based distribution.

## Contents

- `bin/` - Essential user binaries (copied from usr/bin)
- `sbin/` - Essential system binaries (copied from usr/bin)
- `boot/` - Boot files and kernels
- `dev/` - Device files (empty, created at boot)
- `etc/` - System configuration files
- `home/` - User home directories
- `lib/` - Shared libraries (copied from usr/lib)
- `lib64/` - 64-bit libraries
- `mnt/` - Mount point for temporary mounts
- `opt/` - Optional/third-party software
- `proc/` - Process information (created at boot)
- `root/` - Root user home
- `run/` - Runtime data (created at boot)
- `srv/` - Service data
- `sys/` - System information (created at boot)
- `tmp/` - Temporary files
- `usr/` - User programs and libraries
- `var/` - Variable data (logs, cache, etc.)

## Quick Start

### 1. Clone and Extract

```bash
# Clone this repository
git clone https://github.com/lucasgertke11-bot/arch_linux_livecd.git
cd arch_linux_livecd

# Combine and extract the split files
cat part_* > arch-base.tar.gz
tar -xzf arch-base.tar.gz
rm arch-base.tar.gz part_*
```

### 2. Prepare the Chroot Environment

```bash
# Mount required filesystems
mount -t proc /proc chroot/proc
mount -t sysfs /sys chroot/sys
mount -o bind /dev chroot/dev

# Copy DNS configuration
cp /etc/resolv.conf chroot/etc/resolv.conf

# Enter the chroot
arch-chroot chroot
```

## Kernel and Boot

### How the Kernel Works

The `boot/` directory contains:
- `vmlinuz-*` - The Linux kernel (compressed)
- `initramfs-*.img` - Initial RAM filesystem
- `intel-ucode.img` / `amd-ucode.img` - CPU microcode updates

For a functional LiveCD, you'll need:
1. A kernel (`vmlinuz-linux`)
2. An initramfs (`initramfs-linux.img`)
3. Bootloader configuration (GRUB/systemd-boot)

### Bootloader Configuration (GRUB)

Create `/etc/default/grub`:

```bash
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="YourDistro"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
```

Generate config:
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### EFI Boot (UEFI)

For UEFI systems:
```bash
# Install GRUB for UEFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

## LiveCD Configuration

### Pacman Repository Setup

Edit `/etc/pacman.conf`:

```ini
[core]
SigLevel = Required DatabaseOptional
Server = https://mirror.archlinux.org/$repo/os/$arch

[extra]
SigLevel = Required DatabaseOptional
Server = https://mirror.archlinux.org/$repo/os/$arch

[community]
SigLevel = Required DatabaseOptional
Server = https://mirror.archlinux.org/$repo/os/$arch
```

### Initramfs Configuration

Edit `/etc/mkinitcpio.conf`:

```bash
MODULES=(ext4 btrfs)
BINARIES=()
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

Regenerate:
```bash
mkinitcpio -P
```

## Calamares Installer

### Basic Configuration

The `calamares/` directory contains basic configuration for the Calamares installer.

### Required Packages

Install Calamares:
```bash
pacman -S calamares
```

### Module Configuration

Key Calamares modules:
- `bootloader` - GRUB configuration
- `partition` - Disk partitioning
- `users` - User account creation
- `locale` - Language and keyboard
- `packagemodule` - Package installation (optional)

### Creating ISO

```bash
# Using Arch ISO tools
# 1. Create a working directory
mkdir -p ~/livecd/{iso,sfs}

# 2. Copy your prepared system
cp -rf chroot/* sfs/

# 3. Create squashfs
mksquashfs sfs rootfs.squashfs -comp xz

# 4. Create ISO
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso-size 4G \
  -o mydistro.iso \
  -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin \
  -eltorito-boot boot/syslinux/isolinux.bin \
  -boot-load-size 4 \
  -no-emul-boot \
  -boot-info-table \
  -eltorito-catalog boot/syslinux/isolinux.cat \
  -no-pad \
  iso/
```

## Customization

### Adding Desktop Environment

```bash
# KDE Plasma
pacman -S plasma

# GNOME
pacman -S gnome

# XFCE
pacman -S xfce4

# Add display manager
pacman -S sddm   # for KDE
pacman -S gdm    # for GNOME
pacman -S lightdm
```

### Branding

Edit `/etc/os-release`:

```ini
NAME="Your Distro"
PRETTY_NAME="Your Distro"
ID=yourdistro
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL=https://yourdistro.org/
DOCUMENTATION_URL=https://wiki.yourdistro.org
SUPPORT_URL=https://forum.yourdistro.org
BUG_REPORT_URL=https://bugs.yourdistro.org
LOGO=yourdistro
```

## Technical Notes

### Filesystem Hierarchy

- `/bin` → Now real directory (previously symlink to `/usr/bin`)
- `/sbin` → Now real directory (previously symlink to `/usr/bin`)
- `/lib` → Now real directory (previously symlink to `/usr/lib`)
- `/lib64` → Now real directory (previously symlink to `/usr/lib`)

### LiveCD Boot Process

1. **BIOS/UEFI** loads bootloader from USB/DVD
2. **Bootloader** (GRUB/Syslinux) loads kernel + initramfs
3. **Kernel** boots with initramfs (contains early userspace)
4. **Init scripts** mount the real root filesystem (squashfs)
5. **Systemd** starts all services
6. **Display Manager** shows login screen

### Required Services

Enable essential services:
```bash
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd
systemctl enable NetworkManager
systemctl enable haveged  # for entropy
```

## License

This is base system files from Arch Linux. See [archlinux.org](https://archlinux.org) for original licensing.

## Resources

- [Arch Wiki](https://wiki.archlinux.org)
- [Calamares Documentation](https://calamares.io/docs/)
- [DistroFroger Studio](https://github.com/yourusername/distrofrog-studio)
