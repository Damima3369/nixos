{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:

{
    nixpkgs.config.allowUnfree = true;

    imports = [
        ./ssh.nix
        ./fish.nix
        ./doublecmd/doublecmd.nix
        ./obs-studio/obs.nix
        ./waydroid.nix
        ./steam.nix
        ./virtualbox.nix
    ];

  environment.systemPackages = let
    stable = with pkgs; [
      # --- Системные утилиты и Терминал ---
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
      usbutils
      f3
      pay-respects

      # --- Разработка и Скрипты ---
      vscode
      python314
      #pipx

      # --- Работа с дисками и ФС ---
      gparted
      gnome-disk-utility
      kdePackages.partitionmanager

      # --- Офис, Заметки и Обучение ---
      libreoffice-fresh
      obsidian
      klavaro
      qalculate-qt

      # --- Мультимедиа (Аудио / Видео) ---
      mpv
      vlc
      ffmpeg-full
      qpwgraph
      yt-dlp
      ytfzf

      # --- Интернет и Мессенджеры ---
      google-chrome
      discord
      thunderbird
      opensnitch-ui

      # --- Специфичный софт KDE ---
      kdePackages.krdc
      kdePackages.kompare
      kdePackages.kleopatra

      # --- Интеграция, Виртуализация и Смартфоны ---
      scrcpy
      android-tools

      # --- Игры ---
      prismlauncher
      jdk25
    ];
    
    unstable = with pkgs-unstable; [
      ayugram-desktop
    ];
  in stable ++ unstable;

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ zlib libgcc ];
    };
    throne = {
      enable = true;
      tunMode.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
    zsh = {
      enable = true;
      interactiveShellInit = ''
        setopt CORRECTALL
        eval "$(pay-respects zsh)"
        alias fuck=f
      '';
    };
    command-not-found.enable = true;
    bash.interactiveShellInit = ''
      eval "$(pay-respects bash)"
      alias fuck=f
    '';
    fish = {
      enable = true;
      interactiveShellInit = ''
        pay-respects fish | source
        alias fuck=f
      '';
    };
  };

  #services = {
  #  opensnitch.enable = true;
  #};

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  fonts = {
    packages = with pkgs; [
        corefonts     # Microsoft core fonts
        vista-fonts   # Microsoft ClearType fonts
        apple-emoji.packages.${pkgs.stdenv.hostPlatform.system}.default   # Apple Emoji font
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Apple Color Emoji" ];
      };
    };
  };  
}
