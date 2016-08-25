{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc path file_error ];
  depsSha256 = "19rxx1ccwih3cacym2iqwvajk6pwgkhh7jcy2nvjjbvlm6xzx75q";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
