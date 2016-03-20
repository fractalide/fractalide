{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "file_desc" "key_value" ];
  depsSha256 = "111dqnfghwl3ra8vmda1z6qmfpg7af1m3dz6wknbfmmqp0rz6k8n";
  postConfigure = "ls -la";

  meta = with stdenv.lib; {
    description = "Component: Serialize JSON Decode a particular item from a json structure";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/serialize/json/decode/extractKVfromVec;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
