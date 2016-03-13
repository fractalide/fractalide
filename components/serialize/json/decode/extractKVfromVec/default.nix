{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "file" "key_value"];
  depsSha256 = "1q0sy6bxcv7iv340f73rk8931ql2sh8b40zw1nf6n29ahwlm0fg0";
  postConfigure = "ls -la";

  meta = with stdenv.lib; {
    description = "Component: Serialize JSON Decode a particular item from a json structure";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/serialize/json/decode/extractKVfromVec;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
