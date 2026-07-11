{ config, pkgs, secret, ... }:
{
  environment.etc."nextcloud-admin-pass".text = secret.nextcloudAdminPassword;
  services.nextcloud = {
    enable = true;
    https = true;
    package = pkgs.nextcloud33;
    hostName = secret.nextcloudDomainAddr;
    config = {
      adminpassFile = "/etc/nextcloud-admin-pass";
      dbtype = "pgsql";
    };
    database.createLocally = true;
    settings = {
      trusted_domains = [
        "${config.services.nextcloud.hostName}"
        "192.168.1.108"
      ];
      trusted_proxies = [
        "192.168.1.1"
      ];
      overwriteprotocol = "https";
    };
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;       # Перенаправляет HTTP на HTTPS (порт 80 -> 443)
    enableACME = false;    # Выключаем Let's Encrypt (у нас самоподписанный / локальный контур)

    sslCertificate = "/var/lib/nginx/ssl/nextcloud.crt";
    sslCertificateKey = "/var/lib/nginx/ssl/nextcloud.key";
  };

  systemd.services.nginx-ssl-gen = {
    description = "Generate self-signed TLS certificate for Nextcloud Nginx";
    before = [ "nginx.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      UMask = "0077";
    };
    script = ''
      mkdir -p /var/lib/nginx/ssl
      if [ ! -e /var/lib/nginx/ssl/nextcloud.crt ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 \
          -newkey rsa:2048 \
          -keyout /var/lib/nginx/ssl/nextcloud.key \
          -out /var/lib/nginx/ssl/nextcloud.crt \
          -subj "/CN=${config.services.nextcloud.hostName}"
        chown -R nginx:nginx /var/lib/nginx/ssl
        chmod 755 /var/lib/nginx
      fi
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
