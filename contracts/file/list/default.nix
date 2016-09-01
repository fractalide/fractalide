{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xc5286a3290514068;

  struct FileList {
      files @0 :List(Text);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes aspects of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/file;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
