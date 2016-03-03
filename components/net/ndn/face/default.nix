{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "1j9kjxykir69n2vskfribgj4xyz3n94622x5v6by07d2ar70qngi";

  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Face";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/face;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
