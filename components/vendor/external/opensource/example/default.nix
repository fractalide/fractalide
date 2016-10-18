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
  repo = https://github.com/fractalide/fractalide_external_opensource_example/archive/c94d812f5acb0f9317d62f51cd7363c3f4deb2f0.tar.gz;
  external_opensource_nand_gate = import (fetchTarball repo)  {inherit pkgs support contracts components;};
  in
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    '${maths_boolean}:(boolean=true)' -> a nand(external_opensource_nand_gate:${keybase_user}) output -> input io_print(${maths_boolean_print})
    '${maths_boolean}:(boolean=true)' -> b nand()
    '';

    meta = with stdenv.lib; {
      description = "Subnet: testing file for sjm";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
