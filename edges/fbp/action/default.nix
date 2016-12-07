{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xf61112f60e36f395;

    struct FbpAction {
      union {
        add @0 :Add;
        remove @1 :Text;
        connect @2 :Connect;
        send @3 :Send;
        connectSender @4 :ConnectSender;
      }
    }

    struct Add {
           name @0 :Text;
           comp @1 :Text;
    }

    struct Connect {
           oName @0 :Text;
           oPort @1 :Text;
           oSelection @2 :Text;
           iName @3 :Text;
           iPort @4 :Text;
           iSelection @5 :Text;
    }

    struct ConnectSender {
           name @0 :Text;
           port @1 :Text;
           selection @2 :Text;
           output @3 :Text;
    }

    struct Send {
           comp @0 :Text;
           port @1 :Text;
           selection @2 :Text;
    }
  '';
}
