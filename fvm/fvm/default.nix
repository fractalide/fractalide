{pkgs
  , stdenv ? pkgs.stdenv
  , rustUnstable ? support.rustUnstable
  , rustRegistry ? support.rustRegistry
  , buildRustPackage ? support.buildRustPackage
  , upkeepers ? support.upkeepers
  , support
  , libfvm
  }:

  with rustUnstable rustRegistry;

  buildRustPackage rec {
    version = "0.1.0";
    name = "fvm-${version}";
    src = ./.;
    depsSha256 = "0nqga8bd44r0024rba0x24cnyws2bgdjfjniwczsk2pyrg387kb7";

    configurePhase =  ''
    mkdir -p $out/bin
    ln -s ${libfvm}/bin/libfvm.so $out/bin/libfvm.so
    '';

    meta = with stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ agpl3Plus ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie ];
    };
  }

