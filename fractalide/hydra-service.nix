{ config, pkgs, ... }:

let
hydra = (import <nixpkgs> {}).fetchgit {
  url = https://github.com/NixOS/hydra;
  rev = "f11ce7e2195c00ba464ec2a70617034cfc9ef79a";
  sha256 = "06gxwlb6sh3qcaida2mbd2flzci9npwrwsxgpm5j7wa1ynqyhjf1";
};
in
{
  require = [ "${hydra}/hydra-module.nix" ];
  services = {
    postfix = {
      enable = true;
      setSendmail = true;
    };
    hydra = {
      enable = true;
      dbi = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
      package = (import "${hydra}/release.nix" {}).build.x86_64-linux;
      hydraURL = "https://hydra.example.com/";
      listenHost = "localhost";
      port = 3000;
      minimumDiskFree = 5;
      minimumDiskFreeEvaluator = 2;
      notificationSender = "hydra@example.com";
      logo = null;
      debugServer = false;
    };
    # Hydra requires postgresql to run
    postgresql.enable = true;
    postgresql.package = pkgs.postgresql;

    # frontend http/https server
#    nginx.enable = true;
#    nginx.config = pkgs.lib.readFile /root/nginx.conf;
#    authentication = pkgs.lib.mkOverride 10 ''
#    host hydra all 127.0.0.1/8 trust
#    local all all trust
#    '';
  };
}
