{ config, pkgs, ... }:
{
    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "prohibit-password";
        };
    };

    users.users.damima ={
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVhm3XvDm3brOjtMnMSLcm0GjBuHLQq3uofbcLOq71I damima@192.168.1.108"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSSSIbn6zIjK6MIh/HcoGZFeSUaTUa+rcf6ckCDeX/T root@a0d7b954-ssh"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRqUXQ14szEtlLWnmj6TQHbkYxLibMaeAXVS3Ion8Wp damima@orangepi4"
        ];
    };
}
