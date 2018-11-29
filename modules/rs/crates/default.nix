{ lib, buildPlatform, buildRustCrate, buildRustCrateHelpers, cratesIO, fetchgit, edgesModule, rustc, makeWrapper, stdenv }:

let
  mapFeatures = features: map (fun: fun { features = features; });
  crates = import ./Cargo.nix { inherit lib buildPlatform buildRustCrate buildRustCrateHelpers cratesIO fetchgit; }; in
crates // rec {
  rustfbp_0_3_34 = { features?(crates.rustfbp_0_3_34_features {}) }: (crates.rustfbp_0_3_34_ {
    dependencies = mapFeatures features ([ crates.env_logger_0_5_13 libloading_0_5_0 crates.threadpool_1_7_1 ]);
  }).override (args: {
    preConfigure = "cp ${edgesModule.out}/edges.rs src";
  });
  generate_msg_0_1_0 = if stdenv.isDarwin then f: (crates.generate_msg_0_1_0 f).overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
    postFixup = ''
      wrapProgram $out/bin/generate_msg --prefix DYLD_LIBRARY_PATH : ${rustc}/lib
    '';
  }) else crates.generate_msg_0_1_0;
  libloading_0_5_0 = f: (crates.libloading_0_5_0 f).override (args: {
    patches = [ (builtins.toFile "libloading-darwin.diff" ''
      diff --git a/build.rs b/build.rs
      index 88c8c5fa..f3930fd7 100644
      --- a/build.rs
      +++ b/build.rs
      @@ -12,7 +12,7 @@ fn main(){
               // netbsd claims dl* will be available to any dynamically linked binary, but I haven’t
               // found any libraries that have to be linked to on other platforms.
               // What happens if the executable is not linked up dynamically?
      -        Ok("openbsd") | Ok("bitrig") | Ok("netbsd") | Ok("macos") | Ok("ios") => {}
      +        Ok("openbsd") | Ok("bitrig") | Ok("netbsd") | Ok("macos") | Ok("darwin") | Ok("ios") => {}
               Ok("solaris") => {}
               // dependencies come with winapi
               Ok("windows") => {}
    '') ];
  });
}
