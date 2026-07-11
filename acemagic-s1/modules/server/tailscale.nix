{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;  # Включаем пересылку IPv4
    "net.ipv6.conf.all.forwarding" = 1;  # Если используешь IPv6
  };
}
