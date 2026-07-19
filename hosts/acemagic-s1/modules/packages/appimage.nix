{ config, pkgs, lib, ... }:
{
  programs = {
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
}