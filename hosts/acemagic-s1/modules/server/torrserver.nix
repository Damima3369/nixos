{ ... }:
{
  services.torrserver = {
    enable = true;
    openFirewall = true;
    enableGst = false;
  };
}
