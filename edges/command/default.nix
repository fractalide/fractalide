{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntuple_tuple_tt list_text prim_text ];
  schema = with edges; ''
    @0xdfa17455eb3bee21;
    using ListNtupleTupleTt = import "${list_ntuple_tuple_tt}/src/edge.capnp";
    using ListText = import "${list_text}/src/edge.capnp";
    using Text = import "${prim_text}/src/edge.capnp";

    struct Command {
      name @0 : Text.Text;
      singles @1 : ListText.ListText;
      kvs @2 : ListNtupleTupleTt.ListNtupleTupleTt;
      iips @3 : ListText.ListText;
    }
  '';
}
