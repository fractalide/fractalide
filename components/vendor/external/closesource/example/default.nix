{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet, genName
  , maths_boolean_print
  , maths_boolean
  , ...}:
  let
  repo = https://github.com/fractalide/fractalide_external_closesource_example/archive/4948180edab0593895cae225197cc43d0101fccc.tar.gz;
  external_closesource_nand_gate = import (fetchTarball repo)  {inherit pkgs support contracts components;};
  in
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    '${maths_boolean}:(boolean=true)' -> a nand(${external_closesource_nand_gate}) output -> input io_print(${maths_boolean_print})
    '${maths_boolean}:(boolean=true)' -> b nand()
    '';

    meta = with stdenv.lib; {
      description = "Subnet: testing file for sjm";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
