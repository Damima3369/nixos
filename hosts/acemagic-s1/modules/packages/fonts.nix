{ config, pkgs, lib, pkgs-unstable, inputs, winapps, apple-emoji, ... }:
{
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