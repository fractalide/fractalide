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
      repo = "frac_workbench";
      rev = "20ce03ba59c27fdaefedf71b622cab70dc4a38a7";
      sha256 = "0j113s60dmxmwgsvbhwaw048zqmm5bpgi3lalv6g29xldsj8i06k";
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
