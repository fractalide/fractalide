{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [
      PrimText
      PrimVoid
      CoreActionAdd
      CoreActionConnect
      CoreActionConnectSender
      CoreActionSend
    ];
  schema = with edges; ''
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
