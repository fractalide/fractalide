{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xc5286a3290514068;

    struct FileList {
        files @0 :List(Text);
    }
  '';
}
