{ config, pkgs, ...}:
{
    boot.kernelModules = [ "i915" "i2c-dev" "i2c-i801" ];  # i2c для Intel N100
    environment.systemPackages = with pkgs; [ ddcutil i2c-tools ];  # Утилита для DDC/CI


    # Права для I2C
    users.groups.i2c = {};  # Явно создаём группу i2c
    users.users.damima.extraGroups = [ "i2c" ];  # Добавляем в группу i2c
    # udev-правила для группы i2c
    services.udev.extraRules = ''
        SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
    '';
}
