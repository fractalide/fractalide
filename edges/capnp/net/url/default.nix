{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct NetUrl {
           url @0 :Text;
    }
  '';
}
