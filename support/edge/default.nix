{ buffet, genName }:
{
  rs = import ./rs { inherit buffet genName; };
  idr = import ./idr { inherit buffet genName; };
}
