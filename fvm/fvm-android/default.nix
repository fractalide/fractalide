{pkgs
  , stdenv ? pkgs.stdenv
  , support}:

  let
  apk-build = support.apk-builder;
  llvmShared = pkgs.llvmPackages_37.llvm.override { enableSharedLibraries = true; };
  forceBundledLLVM = true;
  rust = support.rustcMaster.overrideDerivation (oldAttrs: {
    forceBundledLLVM = forceBundledLLVM;
    configureFlags =
    ["--target=arm-linux-androideabi --arm-linux-androideabi-ndk=${support.ndk-standalone-toolchain}"] ++
    [ "--enable-local-rust" "--local-rust-root=$snapshot" "--enable-rpath" ]
    ++ [ "--release-channel=stable" ]
    ++ [ "--default-linker=${stdenv.cc}/bin/cc" "--default-ar=${stdenv.cc.binutils}/bin/ar" ]
    ++ stdenv.lib.optional (stdenv.cc.cc ? isClang) "--enable-clang"
    ++ stdenv.lib.optional (!forceBundledLLVM) "--llvm-root=${llvmShared}";
    });
  in
  rust
