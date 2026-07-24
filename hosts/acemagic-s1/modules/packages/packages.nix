{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:
{
    nixpkgs.config.allowUnfree = true;

    imports = [
        ./ssh.nix
        ./fish.nix
        ./doublecmd/doublecmd.nix
        ./obs.nix
        ./cryptography/veracrypt.nix
        ./cryptography/gnupg.nix
        ./diskpartition.nix
        ./fonts.nix
        ./shell.nix
        ./virtualization.nix
        ./kde.nix
        ./appimage.nix
        ./nix-ld.nix
        ./throne.nix
        ./games.nix
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
      f3

      # --- Разработка и Скрипты ---
      vscode
      python314
      #pipx

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
      #opensnitch-ui

      # --- Интеграция, Виртуализация и Смартфоны ---
      scrcpy
      android-tools
    ];
    
    unstable = with pkgs-unstable; [
      ayugram-desktop
    ];
  in stable ++ unstable;
}
