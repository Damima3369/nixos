{ pkgs, ... }:

{
  # 1. Системные пакеты (добавляем roc-toolkit, чтобы модули PipeWire видели библиотеки ROC)
  environment.systemPackages = with pkgs; [
    audacity
    roc-toolkit
  ];

  # 2. Открываем ROC-порты в файрволе
  networking.firewall.allowedUDPPorts = [
    10001
    10002
  ];

  # 3. Настройка PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;

    # Самый надежный способ доставки чистого конфига в PipeWire без синтаксических ошибок Nix
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-roc-input.conf" ''
        context.modules = [
          {
            name = libpipewire-module-roc-source
            args = {
              local.ip = "0.0.0.0"
              resampler.profile = "medium"
              fec.code = "rs8m"
              sess.latency.msec = 60
              local.source.port = 10001
              local.repair.port = 10002
              source.name = "ROC-Phone-Mic"
              source.props = {
                node.name = "roc-source"
                node.description = "Микрофон телефона (Android)"
                media.class = "Audio/Source" # Тот самый ключ, который заставит систему увидеть в этом микрофон
              }
            }
          }
        ]
      '')
    ];
  };
}
