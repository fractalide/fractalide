{stdenv, buildFractalideContract, upkeepers
  , ...}:

buildFractalideContract rec {
  src = ./.;
  searchPaths = [];
  contract = ''
   @0xf6e41344bb789d96;

    struct Tuple {
      first @0 : Text;
      second @1 : Text;
    }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a tuple";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/tuple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
