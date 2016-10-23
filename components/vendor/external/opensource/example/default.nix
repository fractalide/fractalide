{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , maths_boolean_print
  , maths_boolean
  , ...}:
  let
  repo = https://github.com/fractalide/fractalide_external_opensource_example/archive/ef72b8142f8e166cc27365bc0a3ad8a5a143acdf.tar.gz;
  external_opensource_nand_gate = import (fetchTarball repo)  {inherit pkgs support contracts components; fractalide = null;};
  /*repo = ../../../../../../fractalide_external_opensource_example;
  external_opensource_nand_gate = import repo {inherit pkgs support contracts components; fractalide = null;};*/
  in
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    '${maths_boolean}:(boolean=true)' -> a nand(${external_opensource_nand_gate}) output -> input io_print(${maths_boolean_print})
    '${maths_boolean}:(boolean=true)' -> b nand()
    '';

    meta = with stdenv.lib; {
      description = "Subnet: testing file for sjm";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
