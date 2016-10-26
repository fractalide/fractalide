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
      repo = "frac_example_workspace";
      rev = "e07293a2d1c500305a8828ac2228ba79e26152d2";
      sha256 = "113xh2cfj71s9wiya76jp0715pmhbc7r39g82n1gg72a2q7dhby8";
    };
  /*repo = ../../../../frac_example_workspace;*/
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
