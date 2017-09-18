{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreSemanticError {
      path @0 :Text;
      parsing @1 :List(Text);
    }
  '';
}
