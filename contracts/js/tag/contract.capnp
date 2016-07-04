@0xe3c14f149dc7e6cb;

struct JsTag {
    type @0 :Text;
    content @1 :Text;
    css @2 :List(Entry);
    blockCss @3 :List(Entry);
    attributes @4 :List(Entry);
}


struct Entry {
    key @0 :Text;
    value @1 :Text;
}
