{ config, pkgs, lib, ... }:
{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  environment.systemPackages = with pkgs; [ wl-clipboard waydroid-helper ];
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
}
