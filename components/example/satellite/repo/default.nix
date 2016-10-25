{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , maths_boolean_print
  , maths_boolean
  , ...}:
  let
  repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_example_satellite_repo";
      rev = "c8fdc3869e50cfe413c73b57425cc3de84cb87dc";
      sha256 = "1l2nyx931vnyq1hdni6ny63zw5mk6yw56l3ppgkfgjrvhwviw40f";
    };
  /*repo = ../../../../../frac_example_satellite_repo;*/
  external_nand_gate = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    '${maths_boolean}:(boolean=true)' -> a nand(${external_nand_gate}) output -> input io_print(${maths_boolean_print})
    '${maths_boolean}:(boolean=true)' -> b nand()
    '';

    meta = with stdenv.lib; {
      description = "Subnet: testing file for sjm";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
