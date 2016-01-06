{ fractalideSrc ? { outPath = ./.; revCount = 1234; gitTag = "abcdef"; }
, officialRelease ? false
}:

with import <nixpkgs/lib>;

let
  pkgs = import <nixpkgs> {};
  genAttrs' = genAttrs [ "x86_64-linux" ];
  fractalideServer = fractalidePkg:
    { config, pkgs, ... }:
    { imports = [ ./fractalide-module.nix ];
      virtualisation.memorySize = 1024;
      virtualisation.writableStore = true;
      services.fractalide.enable = true;
      services.fractalide.package = fractalidePkg;
      environment.systemPackages = [  ];
    };
in
assert versionAtLeast (getVersion pkgs.nixUnstable) "1.11pre4244_133a421";
rec {
  build = genAttrs' (system:
    with import <nixpkgs> { inherit system; };
    let
    rustRegistry = import ./build-support/rust-packages.nix
    {inherit runCommand fetchFromGitHub git;};
    buildRustPackage = import ./build-support/buildRustPackage.nix
    {inherit stdenv cacert git cargo rustcMaster rustRegistry;};
    in
    buildRustPackage rec {
      name = "fractalide";
      src = ./fractalide;
      depsSha256 = "1lnd16n238v9kr54l1bsmrnp7qqaf9nk607vmd6s26vadipxd8g1";
      meta = with stdenv.lib; {
        description = "Fractalide Virtual Machine";
        homepage = https://github.com/fractalide/fractalide;
        license = with licenses; [ agpl3Plus ];
        maintainers = [ maintainers.sjmackenzie ];
      };
    });

  tests.install = genAttrs' (system:
    with import <nixpkgs/nixos/lib/testing.nix> { inherit system; };
    simpleTest {
      machine = fractalideServer build.${system};
      testScript =
        ''
          $machine->waitForJob("fractalide");
        '';
    });
}
