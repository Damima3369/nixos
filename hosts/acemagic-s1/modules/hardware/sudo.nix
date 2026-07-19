{ config, pkgs, ... }:
{
    security.sudo.extraRules = [
        {
            users = [ "damima" ];
            commands = [
                {
                    command = "ALL" ;
                    options = [ "NOPASSWD" ];
                }
            ];
        }
    ];
}
