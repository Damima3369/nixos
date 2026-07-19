{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kdenlive
    kdePackages.plasma-browser-integration
    kdePackages.kdialog
    kdePackages.krdc
    kdePackages.kompare
    kdePackages.kleopatra
  ];
}
