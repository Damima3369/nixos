{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:
{
  environment.systemPackages = with pkgs; [
    pay-respects
  ];

  programs = {
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
}