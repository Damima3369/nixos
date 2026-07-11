{ config, pkgs, ...}:
{
    hardware.bluetooth.enable = true;  # Включает Bluetooth
    hardware.bluetooth.powerOnBoot = true;  # Автозапуск на старте
    hardware.enableAllFirmware = true;  # Для фирмваре Intel N100
    services.blueman.enable = false;  # GUI менеджер для Bluetooth (BlueMan)
}
