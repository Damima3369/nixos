{ config, pkgs, ... }:
{
  fileSystems = {
    "/ramdisk" = {
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
    "/run/media/damima/Data" = {
      device = "/dev/disk/by-uuid/2998260c-8601-467f-ba47-b67af7608859";
      fsType = "btrfs";
      options = [
        "nofail"
        "noatime"
        "compress=zstd:3"
      ];
    };
    "/run/media/damima/Torrents" = {
      device = "/dev/disk/by-uuid/343228d5-98ff-4672-ad6f-a8b247e27e4a";
      fsType = "btrfs";
      options = [
        "nofail"
        "noatime"
        "compress=zstd:3"
        "noauto"
        "x-systemd.automount"
      ];
    };
  };

  services = {
    devmon.enable = true;
    udisks2.enable = true;
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    beesd.filesystems = {
      Data = {
        spec = "UUID=2998260c-8601-467f-ba47-b67af7608859";
        hashTableSizeMB = 128;
        verbosity = "crit";
        extraOptions = [ "--loadavg-target" "3.0" ];  
      };
      Torrents = {
        spec = "UUID=343228d5-98ff-4672-ad6f-a8b247e27e4a";
        hashTableSizeMB = 256;
        verbosity = "crit";
        extraOptions = [ "--loadavg-target" "3.0" ];  
      };
      System = {
        spec = "UUID=96ab00a6-bae4-4878-b6c9-0e2f8cde12c4";
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
