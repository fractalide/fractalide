{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [
      prim_text
      prim_void
      core_action_add
      core_action_connect
      core_action_connect_sender
      core_action_send
    ];
  schema = with edges; ''
    @0xf61112f60e36f395;

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
