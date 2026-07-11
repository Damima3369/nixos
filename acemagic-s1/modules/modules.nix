{ config, pkgs, ... }:

{
  imports =
    [
      ./kde/kde.nix
      ./packages/packages.nix
      ./hardware/hardware.nix
      ./server/server.nix
    ];
}
