{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xd9a3ed03c95db4cc;

   struct ValueString {
       value @0 :Text;
   }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple value of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/values/string;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
