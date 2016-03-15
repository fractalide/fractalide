@0xfbd616f1e140a67e;

struct UiPosition {
  x :union {
    none @0 :Void;
    right @1 :Float64;
    left @2 :Float64;
  }
  y :union {
    none @3 :Void;
    top @4 :Float64;
    bottom @5 :Float64;
  }
}
