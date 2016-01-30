{pkgs
  , androidsdk ? pkgs.androidsdk
  , androidndk ? pkgs.androidndk
  , ndk-standalone-toolchain ? support.ndk-standalone-toolchain
  , jdk ? pkgs.jdk
  , ant ? pkgs.ant
  , rustcMaster ? support.rustcMaster
  , rustRegistry ? support.rustRegistry
  , support}:

  let

  rust = rustcMaster.overrideDerivation (oldAttrs: {
    configureFlags = "--target=arm-linux-androideabi --arm-linux-androideabi-ndk=${ndk-standalone-toolchain}";
    });
  apk-build = import ./apk-builder.nix {};
  in
  rust
