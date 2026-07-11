{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/modules.nix
  ];

  # --- Загрузчик (GRUB c UEFI и автодетектом Windows) ---
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = lib.mkForce true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;
  boot.kernel.sysctl."kernel.sysrq" = 1;
  services.ntp.enable = true;
  boot.initrd.systemd.enable = true;

  # --- Память и Своп ---
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
    priority = -10;         
  }];
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 75;
  };

  # --- Сетевые настройки ---
  networking.hostName = "acemagic-s1";
  # networking.wireless.enable = true; 
  networking.networkmanager.enable = true;

  # --- Время и Локализация ---
  time = {
    timeZone = "Europe/Moscow";
    hardwareClockInLocalTime = true;
  };
  services.timesyncd.enable = true;

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # --- Графическая оболочка (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- Автоматический вход ---
  services.displayManager.autoLogin = {
    enable = true;
    user = "damima";
  };

  # --- Звуковая подсистема (Pipewire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Печать ---
  services.printing.enable = true;

  # --- Настройки пользователя ---
  users.users.damima = {
    isNormalUser = true;
    description = "Дмитрий";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "damima";
  };
  
  # --- Базовый софт ---
  programs.firefox.enable = true;

  # --- Системные параметры и Оптимизация Nix ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };
}