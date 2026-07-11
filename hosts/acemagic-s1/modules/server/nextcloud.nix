{ config, pkgs, ... }:
{
  environment.etc."nextcloud-admin-pass".text = secret.nextcloudAdminPassword;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "localhost";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "pgsql";
  };
}