{ buffet }:

{
  rs = import ./rs { inherit buffet; };
  purs = import ./purs { inherit buffet; };
}
