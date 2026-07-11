{ config, pkgs, ... }:
{
  imports = [
    ./smb.nix
    ./torrserver/torrserver.nix
    ./syncthing.nix
    ./tailscale.nix
    ./qbittorrent.nix
    ./nextcloud.nix
    #./rdp.nix
  ];
}
