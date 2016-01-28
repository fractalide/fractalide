{ }:

let
f = import ./default.nix {};
in
{doc = import ./doc{}
; components = f.components
; contracts = f.contracts
; contract_lookup = f.support.contract_lookup
; component_lookup = f.support.component_lookup
; fvm = f.fvm
; mobile = (import ./build-support/mobile {
      buildPlatformVersions = [ "16" "17" "18" ]
      ;emulatePlatformVersions = [ "16" "17" "18" ]
      ;abiVersions = [ "armeabi-v7a" "x86" ];}).emulate_fractalide_release.host_x86_64-linux.build_18.emulate_18.x86;
}
