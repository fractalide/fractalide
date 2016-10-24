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
      rev = "6417219cfaf7d2fe450e19f52839aca5eb6c81de";
      sha256 = "1gj3inlmg7rb2fbwajn7xln23lfbgahg333mcn3iczjfw1bfk0jn";
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
