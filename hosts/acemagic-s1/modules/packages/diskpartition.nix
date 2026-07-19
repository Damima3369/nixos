{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    # --- Работа с дисками и ФС ---
    gparted
    gnome-disk-utility
    kdePackages.partitionmanager
    usbutils

    # --- Поддержка файловых систем ---
    btrfs-progs      # Btrfs
    e2fsprogs        # Ext2, Ext3, Ext4
    xfsprogs         # XFS
    jfsutils         # JFS
    dosfstools       # FAT16, FAT32
    ntfs3g           # NTFS (чтение и запись)
    exfatprogs       # exFAT (современный драйвер)
    hfsprogs         # HFS и HFS+ (Apple)
    f2fs-tools       # F2FS (флеш-память)
    nilfs-utils      # NILFS2

    # --- Дополнительные утилиты для разметки: ---
    parted           # Консольный бэкенд для GParted
    gptfdisk         # Работа с GPT разметкой (gdisk)
    mtools           # Работа с FAT дисками без монтирования
  ];
}