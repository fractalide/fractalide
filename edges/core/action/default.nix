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

    using CoreActionAdd = import "${core_action_add}/src/edge.capnp";
    using CoreActionConnect = import "${core_action_connect}/src/edge.capnp";
    using CoreActionConnectSender = import "${core_action_connect_sender}/src/edge.capnp";
    using CoreActionSend = import "${core_action_send}/src/edge.capnp";

    struct CoreAction {
      union {
        add @0 :CoreActionAdd.CoreActionAdd;
        remove @1 :Text;
        connect @2 :CoreActionConnect.CoreActionConnect;
        send @3 :CoreActionSend.CoreActionSend;
        connectSender @4 :CoreActionConnectSender.CoreActionConnectSender;
        halt @5 :Void;
      }
    }
  '';
}
