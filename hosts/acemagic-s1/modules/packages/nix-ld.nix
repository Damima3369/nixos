{ config, pkgs, lib, ... }:
{
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ zlib libgcc ];
    };
  };
}