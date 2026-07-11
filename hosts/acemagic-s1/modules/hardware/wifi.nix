{ config, pkgs, ... }:
{
    boot.blacklistedKernelModules = [
       "rtw88_8821ce"
    ];

    environment.systemPackages = with pkgs; [
        linuxKernel.packages.linux_latest_libre.rtl8821ce
    ];

    boot.extraModulePackages = [ config.boot.kernelPackages.rtl8821ce ];
}
