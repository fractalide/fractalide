{ buffet }:

{
  rs = import ./rs { inherit buffet; };
  idr = import ./idr { pkgs = buffet.pkgs; };
}
