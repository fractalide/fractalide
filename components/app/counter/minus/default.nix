{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ app_counter ];
  depsSha256 = "0745h7nwq1v5f8d8325pq9kkkhkxn4rpxbr7psndrsbg6w7606k2";

  meta = with stdenv.lib; {
    description = "Component: decrease by one the number";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
