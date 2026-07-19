{ config, pkgs, ... }:

{
  imports =
    [
      ./packages/packages.nix
      ./hardware/hardware.nix
      ./server/server.nix
    ];
}
