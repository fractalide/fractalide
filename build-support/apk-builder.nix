{ stdenv
  , fetchFromGitHub
  , rustUnstable
  , makeWrapper
  , rustRegistry
  , buildRustPackage }:

with rustUnstable rustRegistry;

let
android-rs-glue-src = fetchFromGitHub {
    owner = "tomaka";
    repo = "android-rs-glue";
    rev = "3b087cc69e2d8198701ce27bf88424b21231f906";
    sha256 = "12cp5129prsqr5r4ypl34kvj542id5aiq12l99f8h485394l3ayv";
  };
in
buildRustPackage rec {
  name = "apk-builder";
  src = android-rs-glue-src + /apk-builder;

  depsSha256 = "1wfw7kpffvjw2sscy16y1ib87j1mqv8grhc3dcpdbli6419fsvfs";

  meta = with stdenv.lib; {
    description = "Glue between Rust and Android.";
    homepage = https://github.com/tomaka/android-rs-glue;
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ sjmackenzie ];
  };
}
