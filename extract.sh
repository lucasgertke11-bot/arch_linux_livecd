#!/bin/bash
# Extract Arch Linux Base Files
# Usage: ./extract.sh

echo "Combining split files..."
cat part_* > arch-base.tar.gz

echo "Extracting..."
tar -xzf arch-base.tar.gz

echo "Cleaning up..."
rm -f arch-base.tar.gz part_*

echo "Done! Base files extracted to current directory."
echo ""
echo "Next steps:"
echo "1. Mount required filesystems: mount -t proc /proc chroot/proc"
echo "2. Copy DNS: cp /etc/resolv.conf chroot/etc/resolv.conf"
echo "3. Enter chroot: arch-chroot chroot"
