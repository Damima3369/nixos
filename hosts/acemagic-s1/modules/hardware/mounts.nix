{ config, pkgs, ... }:
{
  fileSystems."/run/media/damima/Data" = {
    device = "/dev/disk/by-uuid/2998260c-8601-467f-ba47-b67af7608859";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "compress=zstd:3"
    ];
  };

  fileSystems."/ramdisk" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ 
      "size=100%" 
      "mode=1777" 
      "nosuid" 
      "nodev" 
      "noexec" 
      "rw"
      "group=users" 
    ];
  };

  services = {
    devmon.enable = true;
    udisks2.enable = true;
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
      };
    };
    beesd.filesystems = {
      Data = {
        spec = "UUID=2998260c-8601-467f-ba47-b67af7608859";
        hashTableSizeMB = 128;
        verbosity = "crit";
        extraOptions = [ "--loadavg-target" "3.0" ];  
      };
    };  
  };

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "100%";  # 100% ОЗУ, но NixOS ограничивает, чтобы не убить систему
  };
}
