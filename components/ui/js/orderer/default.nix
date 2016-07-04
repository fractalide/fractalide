{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create"];
  depsSha256 = "1zqyq3chh2a72dfrcnrz926chi4lbj6ndkdf8bc1xibhlbhi6a1l";

  meta = with stdenv.lib; {
    description = "Component: manage the inside of a js block";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
