{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xf96c29a52799b766;

    struct FbpSemanticError {
      path @0 :Text;
      parsing @1 :List(Text);
    }
  '';
}
