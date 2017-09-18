{ lib }:
location:
  let recurse = directories:
    let
      directory = builtins.head directories;
      capitalize = word: (lib.toUpper (lib.substring 0 1 word) + lib.substring 1 (-1) word);
    in
      if builtins.elem directory [ "rs" "idr" "fvm"] then
        builtins.replaceStrings [" "] ["_"] (toString (builtins.tail directories))
      else if builtins.elem directory [ "rs" "idr" "capnp" ] then
        builtins.replaceStrings [" "] [""] (toString (map capitalize (builtins.tail directories)))
      else
        (recurse (builtins.tail directories));
  in
    recurse (lib.splitString "/" (builtins.toString location))
