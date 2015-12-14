{ stdenv, rustUnstable, makeWrapper }:

with rustUnstable;

buildRustPackage rec {
  name = "boolean-not";
  src = ./.;

  depsSha256 = "0qs6ilpvcrvcmxg7a94rbg9rql1hxfljy6gxrvpn59dy8hb1qccc";
}

