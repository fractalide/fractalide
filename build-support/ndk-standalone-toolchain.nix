{ pkgs
  , stdenv
  , androidndk }:

  stdenv.mkDerivation rec {
    name = "ndk-standalone-toolchain";
    src = androidndk;
    buildInputs = [ pkgs.file ];
    installPhase = ''
    mkdir -p $out/ndk-dir
    ${androidndk}/libexec/android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=arm-linux-androideabi-4.8 \
        --ndk-dir=${androidndk}/libexec/android-ndk-r10e \
        --arch=arm \
        --install-dir=$out
    '';

    meta = with stdenv.lib; {
      description = "Android NDK stand alone toolchain for Android.";
      homepage = https://github.com/tomaka/android-rs-glue;
      license = with licenses; [ asl20 ];
      maintainers = with maintainers; [ sjmackenzie ];
    };
  }
