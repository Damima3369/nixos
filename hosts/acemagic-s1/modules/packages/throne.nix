{ config, pkgs, lib, ... }:
{
  programs = {
    throne = {
      enable = true;
      tunMode.enable = true;
    };
  };
}