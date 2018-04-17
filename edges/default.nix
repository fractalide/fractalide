{ buffet }:
{
  idr = import ./idr { inherit buffet; };
  rs = import ./rs { inherit buffet; };
}
