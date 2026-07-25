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
      enable = true;
      configDir = "/var/lib/hass";
      configWritable = true;
      extraComponents = [
        "isal"
      ];
      config = {
        default_config = {};
        http = {
        };
      };
    };
    
    tailscale = {
      enable = true;
    };
    mosquitto = {
      enable = true;
      listeners = [{
        acl = [ "pattern readwrite #" ];
        settings.allow_anonymous = true;
      }];
    };
    zigbee2mqtt = {
      enable = false;
      settings = {
        homeassistant = true;
        mqtt.server = "mqtt://localhost:1883";
        serial.port = "/dev/ttyUSB0";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.home-assistant.config.http.server_port
    8123

  ];

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
}
