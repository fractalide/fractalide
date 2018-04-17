{ buffet, genName, unifyRustEdges }:
{
  idr = import ./idr { inherit buffet genName; };
  rs = import ./rs { inherit buffet genName unifyRustEdges; };
}
