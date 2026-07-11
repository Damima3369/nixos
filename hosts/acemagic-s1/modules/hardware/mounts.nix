{ config, pkgs, ... }:
{
  fileSystems."/run/media/damima/SSD_NTFS" = {
    device = "/dev/disk/by-label/SSD_NTFS";
    fsType = "ntfs3";
    options = [ "nosuid" "nodev" "x-gvfs-show" "rw" "uid=1000" "gid=100" "auto" "exec" "nofail" "noatime" "discard" ];
  };

  fileSystems."/run/media/damima/01DCBEA27B73AC70" = {
    device = "/dev/disk/by-uuid/01DCBEA27B73AC70";
    fsType = "ntfs3"; # Быстрый ядерный драйвер
    options = [
      "nofail"        # Если диск отключен, система не зависнет при загрузке
      "rw"            # Чтение и запись
      "uid=1000"      # Владелец — damima (чтобы KDE не просил root-пароль)
      "gid=100"       # Группа users
      "windows_names" # Защита от создания файлов с запрещенными в Win символами
      "nosuid"
      "nodev"
      "x-gvfs-show"
      "auto"
      "exec"
      "noatime"
      "discard"
    ];
  };

  fileSystems."/ramdisk" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=100%" "mode=1777" "nosuid" "nodev" "noexec" "rw" ];  # 100% ОЗУ, rw для всех
  };

  # Авто-монтирование через udisks2 (для USB и т.д.)
  services.udisks2.enable = true;
  services.devmon.enable = true;

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "100%";  # 100% ОЗУ, но NixOS ограничивает, чтобы не убить систему
  };
}
