{ buffet }:

{
  rs = import ./rs { inherit buffet; };
  idr = import ./idr { inherit buffet; };
}
