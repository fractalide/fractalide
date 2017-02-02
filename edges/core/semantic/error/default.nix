{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct CoreSemanticError {
      path @0 :Text;
      parsing @1 :List(Text);
    }
  '';
}
