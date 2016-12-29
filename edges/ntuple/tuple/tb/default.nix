{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text prim_bool ];
  schema = with edges; ''
    @0xe21ecb0a38e47f3b;

    using PrimText = import "${prim_text}/src/edge.capnp";
    using PrimBool = import "${prim_bool}/src/edge.capnp";

    struct NtupleTupleTb {
      first @0 : PrimText.PrimText;
      second @1 : PrimBool.PrimBool;
    }
  '';
}
