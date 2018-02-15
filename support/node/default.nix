{ buffet, genName, unifyCapnpEdges, unifyRustEdges }:
{
  idr = import ./idr { inherit buffet genName unifyCapnpEdges; };
  rs = import ./rs { inherit buffet genName unifyCapnpEdges unifyRustEdges; };
}
