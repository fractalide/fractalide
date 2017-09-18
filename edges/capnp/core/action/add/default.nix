{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreActionAdd {
           name @0 :Text;
           comp @1 :Text;
    }
  '';
}
