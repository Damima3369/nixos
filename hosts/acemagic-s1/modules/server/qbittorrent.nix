{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        qbittorrent
    ];

    networking.firewall = {
        allowedTCPPorts = [ 51471 ];
        allowedUDPPorts = [ 51471 ];
    };
}