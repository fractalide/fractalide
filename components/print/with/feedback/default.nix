{ stdenv, buildFractalideComponent, genName, upkeepers
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path value_string ];
  depsSha256 = "1dp3znvzmdd2v6kx1964hc8jdlk143bzsjqryys731kq35r4qnkk";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
