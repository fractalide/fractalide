{ }:

let
f = import ./default.nix {};
in
{components = f.components; contracts = f.contracts; fvm = f.fvm;}
