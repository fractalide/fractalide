{stdenv, buildFractalideContract, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x8c9f81d7489d6d29;

   struct Url {
           url @0 :Text;
   }
  '';

  meta = with stdenv.lib; {
    description = "Contract: url of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/url;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
