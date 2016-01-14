@0x9c951b3548fca4c2;

struct Lexical {
  union {
        bind @0 :Void;
        external @1 :Void;
        comp @2 :Comp;
        port :group {
             name @3 :Text;
             selection @4 :Text;
        }
        iip @5 :Text;
        break @6 :Void;
        start @7 :Text;
        end @8 :Text;
  }
}

struct Comp {
       name @0 :Text;
       sort @1 :Text;
}