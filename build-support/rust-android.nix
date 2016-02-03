{pkgs
  , stdenv ? pkgs.stdenv
  , apk-builder
  , rustcMaster
  , ndk-standalone-toolchain
  }:

  let
  apk-build = apk-builder;
  llvmShared = import <nixpkgs/pkgs/development/compilers/llvm/3.7/default.nix> {enableSharedLibraries = true; };
  forceBundledLLVM = true;
  rust = rustcMaster.overrideDerivation (oldAttrs: {
    forceBundledLLVM = forceBundledLLVM;
    configureFlags =
    ["--target=arm-linux-androideabi --arm-linux-androideabi-ndk=${ndk-standalone-toolchain}"] ++
    [ "--enable-local-rust" "--local-rust-root=$snapshot" "--enable-rpath" ]
    ++ [ "--default-linker=${stdenv.cc}/bin/cc" "--default-ar=${stdenv.cc.binutils}/bin/ar" ]
    ++ stdenv.lib.optional (stdenv.cc.cc ? isClang) "--enable-clang"
    ++ stdenv.lib.optional (!forceBundledLLVM) "--llvm-root=${llvmShared}";
    });
  in
  rust
