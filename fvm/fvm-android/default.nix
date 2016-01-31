{pkgs
  , stdenv ? pkgs.stdenv
  , ndk-standalone-toolchain ? support.ndk-standalone-toolchain
  , rustcMaster ? support.rustcMaster
  , llvmPackages_37 ? pkgs.llvmPackages_37
  , support}:

  let
  llvmShared = llvmPackages_37.llvm.override { enableSharedLibraries = true; };
  forceBundledLLVM = true;
  rust = rustcMaster.overrideDerivation (oldAttrs: {
    forceBundledLLVM = forceBundledLLVM;
    configureFlags =
    ["--target=arm-linux-androideabi --arm-linux-androideabi-ndk=${ndk-standalone-toolchain}"] ++
    [ "--enable-local-rust" "--local-rust-root=$snapshot" "--enable-rpath" ]
    ++ [ "--release-channel=stable" ]
    ++ [ "--default-linker=${stdenv.cc}/bin/cc" "--default-ar=${stdenv.cc.binutils}/bin/ar" ]
    ++ stdenv.lib.optional (stdenv.cc.cc ? isClang) "--enable-clang"
    ++ stdenv.lib.optional (!forceBundledLLVM) "--llvm-root=${llvmShared}";
    });
  apk-build = import ./apk-builder.nix {};
  in
  rust
