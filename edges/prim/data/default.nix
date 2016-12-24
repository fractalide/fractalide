{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xb8d8f4f717136987;

    # Data is a completely arbitrary sequence of bytes.
    
    struct PrimData {
            data @0 :Data;
    }
  '';
}
