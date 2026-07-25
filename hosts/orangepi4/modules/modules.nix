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
    f3
    python314
    #nodejs-slim_26
    (pkgs.writeShellScriptBin "tuya-cli" ''
      exec ${pkgs.nodejs}/bin/npx tuya-cli "$@"
    '')
  ];

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  services = {
    home-assistant = {
      enable = false;
      extraComponents = [
        "isal"
      ];
      config = {
        default_config = {};
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    config.services.home-assistant.config.http.server_port
  ];

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
}
