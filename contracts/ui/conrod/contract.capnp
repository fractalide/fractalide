@0x8860cc647a3c9367;

struct UiConrod {
  union {
    position @0 :Position;
    widget @1 :Widget;
  }       
}

struct Position {
  union {
    lr @0 :List(UiConrod);
    td @1 :List(UiConrod);
  }
}

struct Widget {
  union {
    button @0 :Void;
    text @1 :Void;
  }
} 
