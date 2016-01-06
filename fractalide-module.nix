{ config, pkgs, lib ? pkgs.lib, ... }:
with lib;
let
  cfg = config.services.fractalide;
  mappings = import ./default.nix {};
  fractalideConf = pkgs.writeText "fractalide.toml"
  ''
  [mappings]
  rust-component-lookup = ${mappings.rust-component-lookup}/lib/librust_component_lookup.so
  rust-contract-lookup = ${mappings.rust-contract-lookup}/lib/librust_contract_lookup.so
  '';
  fractalideEnv =
    {
      FRACTALIDE_CONFIG = "${cfg.baseDir}/fractalide.toml";
      FRACTALIDE_DATA = "${cfg.baseDir}";
    };
  env =
    { FRACTALIDE_REMOTE = "daemon";}
    // fractalideEnv // cfg.extraEnv;
in
{
  # interface
  options = {
    services.fractalide = rec {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run Fractalide services.
        '';
      };
      package = mkOption {
        type = types.path;
        #default = pkgs.fractalide;
        description = "The Fractalide package.";
      };
      extraConfig = mkOption {
        type = types.lines;
        description = "Extra lines for the Fractalide configuration.";
      };
      baseDir = mkOption {
        type = types.path;
        default = "/var/fractalide";
        description = ''
          Working directory for Fractalide.
        '';
      };
      extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Extra environment variables for Fractalide.";
      };
    };
  };

  # implementation

  config = mkIf cfg.enable {
    users.extraGroups.fractalide = { };
    users.extraUsers.fractalide =
      { description = "Fractalide";
        group = "fractalide";
        createHome = false;
        useDefaultShell = false;
      };
    nix.trustedUsers = [ "users" ];
    services.fractalide.package = mkDefault ((import ./release.nix {}).build.x86_64-linux);
    services.fractalide.extraConfig = '''';
    environment.systemPackages = [ cfg.package ];
    environment.variables = fractalideEnv;
    systemd.services.fractalide =
      { wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = env;
        preStart = ''
          mkdir -p ${cfg.baseDir}
          chown fractalide.users ${cfg.baseDir}
          chmod 0750 ${cfg.baseDir}

          ln -sf ${fractalideConf} ${cfg.baseDir}/fractalide.toml
          '';
        serviceConfig.ExecStart = "${cfg.package}/bin/fractalide";
        serviceConfig.PermissionsStartOnly = true;
        serviceConfig.User = "fractalide";
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
      };
  };

}
