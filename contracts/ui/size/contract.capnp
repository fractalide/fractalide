@0xb192458d8808e4c1;

struct UiSize {
  w :union {
    none @0 :Void;
    fixed @1 :Float64;
    padded @2 :Float64;
  }
  h :union {
    none @3 :Void;
    fixed @4 :Float64;
    padded @5 :Float64;
  }
}
