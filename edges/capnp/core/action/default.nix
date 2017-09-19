{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [
      PrimText
      PrimVoid
      CoreActionAdd
      CoreActionConnect
      CoreActionConnectSender
      CoreActionSend
    ];
  schema = with edges.capnp; ''
    struct CoreAction {
      union {
        add @0 :CoreActionAdd;
        remove @1 :Text;
        connect @2 :CoreActionConnect;
        send @3 :CoreActionSend;
        connectSender @4 :CoreActionConnectSender;
        halt @5 :Void;
      }
    }
  '';
}
