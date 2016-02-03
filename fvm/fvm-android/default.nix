{pkgs
  , stdenv ? pkgs.stdenv
  , support}:

  let
  apk-build = support.apk-builder;
  rust = support.rust-android;
  in
  rust
