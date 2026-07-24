{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.username = "damima";
  home.homeDirectory = "/home/damima";

  imports = [
    ./packages.nix
  ];

  #home.packages = (import ./packages.nix) pkgs;

  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name  = "Damima";
      user.email = "damima3369@gmail.com";
    };
  };

  programs.plasma = {
    enable = true;
    input.keyboard.numlockOnStartup = "on";

    panels = [
      {
        location = "bottom";
        height = 44;  # Стандарт, измени если нужно

        widgets = [
          # Kickoff (меню)
          "org.kde.plasma.kickoff"

          # Pager
          "org.kde.plasma.pager"

          # Icon-only Task Manager с твоими launchers
          {
            iconTasks = {
              launchers = [
                "preferred://browser"  # Авто браузер
                "applications:com.ayugram.desktop"  # Или полный путь, если не в стандартном месте
                "applications:doublecmd.desktop"
              ];
            };
          }

          # Separator
          "org.kde.plasma.marginsseparator"

          # System Tray (стандартный, с твоими extraItems если нужно)
          "org.kde.plasma.systemtray"

          # Digital Clock (секунды всегда + номера недель)
          {
            digitalClock = {
              calendar.showWeekNumbers = true;
              time.showSeconds = "always";
            };
          }

          # Show Desktop
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
    
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      iconTheme = "breeze-dark";
      cursor.theme = "breeze_cursors";  # Опционально
      wallpaperSlideShow = {
        path = "/run/media/damima/SSD_NTFS/Разобрано/Дом/Обои/слайд-шоу/";
        interval = 60;
      };
    };  

    kwin.titlebarButtons = {
      left = [ "more-window-actions" "keep-above-windows" "on-all-desktops" ];
      right = [ "help" "minimize" "maximize" "close" ];
    };

    configFile = {
      # KFileDialogSettings = {
      #   # "Allow Expansion" = false;
      #   "Automatically select filename extension" = true;
      #   "Breadcrumb Navigation" = false;
      #   "Decoration position" = 2;
      #   "LocationCombo Completionmode" = 5;
      #   "PathCombo Completionmode" = 5;
      #   "Show Bookmarks" = false;
      #   "Show Full Path" = false;
      #   "Show Inline Previews" = true;
      #   "Show Preview" = false;
      #   "Show Speedbar" = true;
      #   "Show hidden files" = false;
      #   "Sort by" = "Name";
      #   "Sort directories first" = true;
      #   "Sort hidden files last" = false;
      #   "Sort reversed" = false;
      #   "Speedbar Width" = 201;
      #   "View Style" = "DetailTree";
      # };
      powerdevilrc."AC.SuspendAndShutdown" = {
        AutoSuspendAction = 0;
        PowerButtonAction = 64;
      };
    };
  };
}