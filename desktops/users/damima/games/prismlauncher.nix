{ config, pkgs, ... }:
{
    home.file.".local/share/PrismLauncher/accounts.json".text = ''
        {
            "accounts": [
                {
                    "entitlement": {
                        "canPlayMinecraft": true,
                        "ownsMinecraft": true
                    },
                    "msa-client-id": "",
                    "type": "MSA"
                },
                {
                    "active": true,
                    "profile": {
                        "capes": [
                        ],
                        "id": "eb240d4b969733efae3adf0d341574a1",
                        "name": "Damima",
                        "skin": {
                            "id": "",
                            "url": "",
                            "variant": ""
                        }
                    },
                    "type": "Offline",
                    "ygg": {
                        "extra": {
                            "clientToken": "34a5bd538e18449ca4094b477a089ce1",
                            "userName": "Damima"
                        },
                        "iat": 1766567320,
                        "token": "0"
                    }
                }
            ],
            "formatVersion": 3
        }
    '';
}