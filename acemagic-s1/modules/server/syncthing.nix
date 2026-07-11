{ config, pkgs, pkgs-unstable, ... }:
{
  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    user = "damima";
    #dataDir = "/home/damima/Syncthing";  # Папка для синхронизации
    configDir = "/home/damima/.config/syncthing";  # Где будет config.xml
    openDefaultPorts = true;  # 22000/tcp, 21027/udp
  };
  users.users.damima.extraGroups = [ "syncthing" ];
  #systemd.tmpfiles.rules = [ "d /home/damima/Syncthing 0775 damima users - -" ];
}
