{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["quadruple"];
  depsSha256 = "0kmbj87wz3mkndpkbg0ly00hvazx1cnrq99r0a7nyv2xdw6w9qzm";

  meta = with stdenv.lib; {
    description = "Component: Print raw unanonymized and anonymized statistics to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
