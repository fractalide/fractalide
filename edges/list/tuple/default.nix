{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ tuple ];
  schema = with edges; ''
    @0xf698d2e1249dada8;
    using Tuple = import "${tuple}/src/edge.capnp";

    struct ListTuple {
        tuples @0 : List(Tuple.Tuple);
    }
  '';
}
