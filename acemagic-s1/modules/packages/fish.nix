{ config, pkgs, ... }:
{
    users.defaultUserShell = pkgs.fish;
    programs.fish.enable = true;
    # environment.etc."fish/config.fish".text = ''
    # set fish_greeting  # Отключает приветствие Fish
    # '';
}
