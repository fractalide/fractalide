{ isTravis ? false
}:

let
  genJobs = pkgs: {
    inherit (pkgs) fractalide;
    rs-tests = import ./tests;
    cardano = (import ./. { inherit pkgs; }).mods.rs.deps.cardano."0.1.0";
    rustfbp = (import ./. {}).mods.rs.deps.rustfbp."0.3.34";
  };
in
  (genJobs (import ./pkgs {})) //
  {
    latest-nixpkgs = genJobs (import ./pkgs { pkgs = import <nixpkgs>; });
    x86_64-darwin = genJobs (import ./pkgs { system = "x86_64-darwin"; }) // {
      latest-nixpkgs = genJobs (import ./pkgs { system = "x86_64-darwin"; pkgs = import <nixpkgs>; });
    };
  } // (import <nixpkgs> {}).lib.optionalAttrs isTravis {
    travisOrder = [ "rs-tests" "fractalide" ];
  }
