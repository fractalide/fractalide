{ pkgs ? import <nixpkgs>}:

let
f = import ./default.nix {};
support = f.support;
in
{doc = import ./doc{}
; components = f.components
; contracts = f.contracts
; contract_lookup = f.support.contract_lookup
; component_lookup = f.support.component_lookup
; fvm = f.fvm
; mobile = import ./fvm/fvm-android { inherit pkgs support;};
}
