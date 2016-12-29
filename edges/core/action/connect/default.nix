{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x8067311a5b6027d2;

    struct CoreActionConnect {
           oName @0 :Text;
           oPort @1 :Text;
           oSelection @2 :Text;
           iName @3 :Text;
           iPort @4 :Text;
           iSelection @5 :Text;
    }
  '';
}
