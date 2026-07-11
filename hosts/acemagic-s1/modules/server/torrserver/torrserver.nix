{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ffmpeg-full
    (pkgs.callPackage (import ./torrserver_pkg.nix) {})
  ];

  systemd.services.torrserver = {
    description = "TorrServer Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.callPackage (import ./torrserver_pkg.nix) {}}/bin/torrserver -d /home/damima/.config/torrserver";
      Restart = "on-failure";
      User = "damima";
      Group = "users";
    };
  };
  users.users.damima.extraGroups = [ "users" ];
  systemd.tmpfiles.rules = [ "d /home/damima/.config/torrserver 0755 damima users - -" ];
  networking.firewall.allowedTCPPorts = [ 8090 ];
}
