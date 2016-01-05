{ pkgs, lib, contracts, rustcMaster }:
let
mapping = pkgs.writeTextFile {
  name = "mapping.rs";
  text = ''
use std::collections::HashMap;
use std::mem::transmute;

#[repr(C)]
pub struct Map {
    pub map: HashMap<&'static str, &'static str>,
}

#[no_mangle]
pub extern "C" fn create() -> *const Map {
    let mut map  = HashMap::<&str, &str>::with_capacity(${
      (builtins.toString (builtins.length (lib.attrValues contracts)))});
${lib.concatMapStringsSep "\n"
    (pkg: "map.insert(\"${pkg.name}\", \"${(lib.last (lib.splitString "/" pkg.outPath))}\");")
    (lib.attrValues contracts)}
    let b = Box::new(Map{ map: map, });
    unsafe { transmute(b) }
}

#[no_mangle]
pub extern "C" fn get(ptr: *const Map, name: &String) -> *const str {
    let map = unsafe { &(*ptr) };
    match map.map.get(&name[..]) {
        None => { "" as *const str },
        Some(hash_name) => { *hash_name as *const str }
    }
}

#[no_mangle]
pub extern "C" fn drop(ptr: *const Map) {
    let _m: Box<Map> = unsafe { transmute(ptr) };
}
'';
    executable = false;
};
in
pkgs.stdenv.mkDerivation rec {
  name = "rust-contract-lookup";
  version = "2015-12-22";
  unpackPhase = "true";
  buildInputs = [ rustcMaster ];
  installPhase = ''
  mkdir -p $out/{src,lib}
  cp ${mapping} $out/src/rust-contract-lookup.rs
  rustc -Cno-stack-check -Copt-level=3 --crate-type=dylib $out/src/rust-contract-lookup.rs --out-dir $out/lib/
  '';
}
