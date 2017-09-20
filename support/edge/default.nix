{ buffet, genName }:
{
  capnp = import ./capnp { inherit buffet genName; };
  rs = import ./rs { inherit buffet genName; };
  idr = import ./idr { inherit buffet genName; };
}
