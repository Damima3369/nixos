{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        doublecmd  # Устанавливаем Double Commander
    ];

    # Копируем текущие настройки в конфиг
    environment.etc."xdg/doublecmd/doublecmd.xml".source = ./doublecmd.xml;
    environment.etc."xdg/doublecmd/colors.json".source = ./colors.json;
    environment.etc."xdg/doublecmd/doublecmd.cfg".source = ./doublecmd.cfg;
    environment.etc."xdg/doublecmd/extassoc.xml".source = ./extassoc.xml;
    environment.etc."xdg/doublecmd/highlighters.xml".source = ./highlighters.xml;
    environment.etc."xdg/doublecmd/history.xml".source = ./history.xml;
    environment.etc."xdg/doublecmd/multiarc.ini".source = ./multiarc.ini;
    environment.etc."xdg/doublecmd/pixmaps.txt".source = ./pixmaps.txt;
    environment.etc."xdg/doublecmd/session.ini".source = ./session.ini;
    environment.etc."xdg/doublecmd/shortcuts.scf".source = ./shortcuts.scf;
    environment.etc."xdg/doublecmd/tabs.xml".source = ./tabs.xml;
}
