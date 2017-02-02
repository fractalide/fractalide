{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    # Data is a completely arbitrary sequence of bytes.

    struct PrimData {
            data @0 :Data;
    }
  '';
}
