{ config, pkgs, ... }:
{
  services.samba.enable = true;
  #services.samba.settings.global.security = "user";
  services.samba.settings = {
    global = {
      workgroup = "WORKGROUP";
      serverString = "NixOS Samba Server";
      serverRole = "standalone server";
      security = "user";
      "invalid users" = [
      ];
      #"map to guest" = "Bad User";
      "map to guest" = "Bad Password";
      "guest account" = "root";
      "usershare allow guests" = "yes";
      # Max perf: SMB3, multi-channel, aio, buffers, no delays/locks
      #"min protocol" = "NT1";
      #"max protocol" = "SMB3_11";
      "server multi channel support" = "yes";
      "use sendfile" = "yes";
      "aio read size" = "1";
      "aio write size" = "1";
      "socket options" = [
        "TCP_NODELAY"
        "IPTOS_LOWDELAY"
        "SO_RCVBUF=1048576"
        "SO_SNDBUF=1048576"
        ];
      "read raw" = "yes";
      "write raw" = "yes";
      "strict locking" = "no";
      "getwd cache" = "yes";
      "smb2 max read" = "10485760";
      "smb2 max write" = "10485760";
      "smb2 max trans" = "10485760";
      "smb2 leases" = "no";
      "deadtime" = "0";
      "max open files" = "16384";
    };
    "!!!root" = {
      path = "/";
      browseable = "yes";
      writable = "yes";
      "guest ok" = "yes";
      public = "yes";
      "create mask" = "0777";
      "directory mask" = "0777";
      "force user" = "root";
      "force group" = "root";
    };

    "!!!!!mounts" = {
      path = "/run/media/damima";
      browseable = "yes";
      writable = "yes";
      "guest ok"= "yes";
      public = "yes";
      "create mask" = "0777";
      "directory mask" = "0777";
      "force user" = "root";
      "force group" = "root";
    };

    "!!!!home" = {
      path = "/home/damima";
      browseable = "yes";
      writable = "yes";
      "guest ok" = "yes";
      public= "yes";
      "create mask" = "0777";
      "directory mask" = "0777";
      "force user" = "root";
      "force group" = "root";
    };

    ramdisk = {
      path = "/ramdisk";
      browseable = "yes";
      writable = "yes";
      "guest ok" = "yes";
      public = "yes";
      "create mask" = "0777";
      "directory mask" = "0777";
      "force user" = "root";
      "force group" = "root";
    };
  };
  users.users.damima.extraGroups = [ "samba" ];
  #systemd.tmpfiles.rules = [ "d /home/damima/shared 0775 damima samba - -" ];
  networking.firewall.allowedTCPPorts = [ 137 138 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 139 445 ];
}
