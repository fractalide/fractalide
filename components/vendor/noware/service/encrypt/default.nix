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
  /*repo = https://github.com/fractalide/fractalide_external_opensource_example/archive/c94d812f5acb0f9317d62f51cd7363c3f4deb2f0.tar.gz;*/
  /*vendor_noware_service_encrypt = import (fetchTarball repo)  {inherit pkgs support contracts components;};*/
  repo = ../../../../../../noware;
  vendor_noware_service_encrypt = import repo {inherit pkgs support contracts components;};
  in
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    '${maths_boolean}:(boolean=true)' -> a nand(${vendor_noware_service_encrypt}) output -> input io_print(${maths_boolean_print})
    '${maths_boolean}:(boolean=true)' -> b nand()
    '';

    meta = with stdenv.lib; {
      description = "Subnet: testing file for sjm";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
