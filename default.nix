{ rs ? null
  , purs ? null
  , pkgs ? (
  let
    pkgs = import <nixpkgs>;
    pkgs_ = (pkgs {});
    rustOverlay = (pkgs_.fetchFromGitHub {
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      rev = "4779fb7776c3d38d78b5ebcee62165e6d1350f74";
      sha256 = "04q6pwlz82qsm81pp7kk7i6ngrslq193v5wchdsrdifbn8cdqgbs";
    });
  in (pkgs {
    overlays = [
      (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
      (self: super: {
        rust = {
          rustc = super.rustChannels.nightly.rust;
          cargo = super.rustChannels.nightly.cargo;
        };
        rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform {
          rustc = super.rustChannels.nightly.rust;
          cargo = super.rustChannels.nightly.cargo;
        });
      })
    ];
  }))
}:
with pkgs;
let
  target = if rs != null then  { name = "rs"; nodes = nodes.rs; node = rs;}
  else if purs != null then { name = "purs"; nodes = nodes.purs; node = purs;}
  else { name = "rs"; nodes = nodes.rs; node = rs;};
  targetNode = (builtins.head (pkgs.lib.attrVals [target.node] target.nodes));
  nodes = import ./nodes { inherit buffet; };
  edges = import ./edges { inherit buffet; };
  support = import ./support { inherit buffet; };
  fractals = import ./fractals { inherit buffet; };
  services = import ./services { inherit buffet; };
  mods = import ./modules { inherit buffet; };
  imsg = support.imsg;
  buffet = {
    support = support;
    edges = edges;
    imsg = imsg;
    nodes = nodes;
    services = services;
    fractals = fractals;
    mods = mods;
    pkgs = pkgs;
  };
  fvm = import (./nodes/fvm + "/${target.name}") { inherit buffet; };
in
{
  inherit buffet nodes edges support services;
  result = if target.node == null
  then fvm
  else pkgs.writeTextFile {
    name = targetNode.name;
    text = "${fvm}/bin/fvm ${targetNode}";
    executable = true;};
}
