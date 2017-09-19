{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    # Data is a completely arbitrary sequence of bytes.

    struct PrimData {
            data @0 :Data;
    }
  '';
}
