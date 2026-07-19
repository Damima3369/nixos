{ config, pkgs, lib, ... }:
{
  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
}