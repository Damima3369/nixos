{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    doublecmd # Устанавливаем Double Commander
  ];

  # Копируем текущие настройки в конфиг
  environment.etc = {
    "xdg/doublecmd/doublecmd.xml".source = ./doublecmd.xml;
    "xdg/doublecmd/colors.json".source = ./colors.json;
    "xdg/doublecmd/doublecmd.cfg".source = ./doublecmd.cfg;
    "xdg/doublecmd/extassoc.xml".source = ./extassoc.xml;
    "xdg/doublecmd/highlighters.xml".source = ./highlighters.xml;
    "xdg/doublecmd/history.xml".source = ./history.xml;
    "xdg/doublecmd/multiarc.ini".source = ./multiarc.ini;
    "xdg/doublecmd/pixmaps.txt".source = ./pixmaps.txt;
    "xdg/doublecmd/session.ini".source = ./session.ini;
    "xdg/doublecmd/shortcuts.scf".source = ./shortcuts.scf;
    "xdg/doublecmd/tabs.xml".source = ./tabs.xml;
  };
}
