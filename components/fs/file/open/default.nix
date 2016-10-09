{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc path file_error ];
  depsSha256 = "1l3h97jmsv0kh1qyyan2wmzq20c6ixaq20c6riars1nvmjv3l795";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
