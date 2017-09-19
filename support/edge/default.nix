{ buffet, genName }:
{
  capnp = import ./capnp { inherit buffet genName; };
  rs = import ./rs { inherit buffet genName; };
}
