{ lib }:
location:
  let recurse = folders:
    let
      folder = builtins.head folders;
      capitalize = foldToCap: (lib.toUpper (lib.substring 0 1 foldToCap) + lib.substring 1 (-1) foldToCap);
    in if folder == "nodes"
      then builtins.replaceStrings [" "] ["_"] (toString (builtins.tail folders))
      else if folder == "edges"
      then builtins.replaceStrings [" "] [""] (toString (map capitalize (builtins.tail folders)))
      else (recurse (builtins.tail folders));
  in recurse (lib.splitString "/" (builtins.toString location))
