{ isTravis ? false
}:

let
  genJobs = pkgs: {
    inherit (pkgs) fractalide rkt-tests;
    rs-tests = import ./tests;
    cardano = (import ./. { inherit pkgs; }).mods.rs.cardano_0_1_0;
    rustfbp = (import ./. {}).mods.rs.rustfbp_0_3_34;
  };
in
  (genJobs (import ./pkgs {})) //
  {
    latest-nixpkgs = genJobs (import ./pkgs { pkgs = import <nixpkgs>; });
    x86_64-darwin = genJobs (import ./pkgs { system = "x86_64-darwin"; }) // {
      latest-nixpkgs = genJobs (import ./pkgs { system = "x86_64-darwin"; pkgs = import <nixpkgs>; });
    };
  } // (import <nixpkgs> {}).lib.optionalAttrs isTravis {
    travisOrder = [ "rs-tests" "rkt-tests" ];
  }
