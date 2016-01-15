@0xaf73df75f011fbb3;

struct File {
    union {
      start @0 :Text;
      text @1 :Text;
      end @2 :Text;
    }
}
