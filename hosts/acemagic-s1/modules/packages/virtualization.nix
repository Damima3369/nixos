{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
    };
    virtualbox = {
      host.enable = true;
    };
    waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };
  users.extraGroups.vboxusers.members = [ "damima" ];
  environment.systemPackages = with pkgs; [ wl-clipboard waydroid-helper distrobox ];
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
}