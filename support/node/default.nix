{ pkgs, genName, unifySchema, buffet }:
{
  idr = import ./idr { inherit buffet genName; };
  rs = import ./rs { inherit pkgs genName unifySchema buffet; };
}
