{ config, pkgs, lib, ... }:
{
    environment.systemPackages = with pkgs; [
        obs-studio
        obs-studio-plugins.wlrobs
        obs-studio-plugins.obs-vaapi
        obs-studio-plugins.obs-vkcapture
        obs-studio-plugins.obs-gstreamer
        obs-studio-plugins.input-overlay
        obs-studio-plugins.obs-multi-rtmp
        obs-studio-plugins.obs-mute-filter
        obs-studio-plugins.obs-pipewire-audio-capture
    ];

    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
}
