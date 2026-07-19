{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:
{
   nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
    ];
    programs = {
        steam = {
            enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
            extraPackages = with pkgs; [ jdk ];
        };
        java = {
            enable = true;
            packages = with pkgs; [ jdk25 ];
            binfmt = true;
        };
    };
    environment.systemPackages = with pkgs; [
        steam-run
        protonup-qt
        lutris
        prismlauncher
    ];
}