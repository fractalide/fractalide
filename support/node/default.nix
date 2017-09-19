{ buffet, genName, unifyCapnpEdges }:
{
  idr = import ./idr { inherit buffet genName unifyCapnpEdges; };
  rs = import ./rs { inherit buffet genName unifyCapnpEdges; };
}
