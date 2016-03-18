@0xf698d2e1249dada8;

struct Tuple {
  first @0 : Text;
  second @1 : Text;
}

struct ListTuple {
    files @0 :List(Tuple);
}
