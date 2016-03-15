@0xa6c0aae2820dca75;

struct UiCreate {
  name @0 :Text;
  sender @1 :UInt64;
  position @2 :Position; 
  size @3 :Size;
  widget @4 :Widget;
  id @5 :Text;
}

struct Position {
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

struct Size {
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

struct Widget {
  union {
    lr @0 :List(Text);
    td @1 :List(Text);
    button @2 :WidgetButton;
    text @3 :WidgetText;
  }
}

struct WidgetButton {
    label @0 :Text;
    enable @1 :Bool;
}

struct WidgetText {
    label @0 :Text;
}
