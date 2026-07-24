{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    git
    wget
    mc
    tree
    fastfetch
    htop
    btop
    screen
    busybox
    p7zip
    rar
    unrar
    f3
    python314
    nodejs-slim_26
    python314Packages.pipx
  ];
}