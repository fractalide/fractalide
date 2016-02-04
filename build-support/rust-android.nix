{pkgs
  , fetchurl
  , stdenv ? pkgs.stdenv
  , rustcMaster
  , ndk-standalone-toolchain
  }:

# https://ghotiphud.github.io/rust/android/cross-compiling/2016/01/06/compiling-rust-to-android.html
# https://github.com/japaric/ruststrap/blob/master/1-how-to-cross-compile.md
# https://github.com/rust-lang/rust-wiki-backup/blob/master/Doc-building-for-android.md

  let
  stdenv_32bit = pkgs.pkgsi686Linux.stdenv;
  zlib_32bit = pkgs.pkgsi686Linux.zlib;
  ncurses_32bit = pkgs.pkgsi686Linux.ncurses;
  llvmShared = pkgs.llvmPackages_37.llvm.override { enableSharedLibraries = true; };
  forceBundledLLVM = true;
  rust = rustcMaster.overrideDerivation (oldAttrs: {
    forceBundledLLVM = forceBundledLLVM;
    nativeBuildInputs = with pkgs; [ file python2 procps ncurses_32bit  zlib_32bit stdenv_32bit];
    preConfigure = ''
        configureFlagsArray+=("--target=arm-linux-androideabi")
        configureFlagsArray+=("--arm-linux-androideabi-ndk=${ndk-standalone-toolchain}")
        configureFlagsArray+=("--host=x86_64-unknown-linux-gnu")
        configureFlagsArray+=("--enable-local-rust")
        configureFlagsArray+=("--jemalloc-root=${pkgs.jemalloc}/lib")
        configureFlagsArray+=("--local-rust-root=$snapshot")
        configureFlagsArray+=("--enable-rpath")
        configureFlagsArray+=("--release-channel=stable")
        configureFlagsArray+=("--default-linker=${pkgs.pkgsi686Linux.stdenv.cc}/bin/cc")
        configureFlagsArray+=("--default-ar=${pkgs.pkgsi686Linux.stdenv.cc.binutils}/bin/ar")
        configureFlagsArray+=("--enable-clang")
        configureFlagsArray+=("--llvm-root=${llvmShared}")
        configureFlagsArray+=("--android-cross-path=${ndk-standalone-toolchain}")
        configureFlagsArray+=("--datadir=$out/share")
        configureFlagsArray+=("--infodir=$out/share/info")
        '';

    });
  in
  rust
