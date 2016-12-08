{ lib }:
location:
  let recurse = folders:
    let folder = builtins.head folders;
    in if folder == "nodes" || folder == "edges"
      then builtins.replaceStrings [" "] ["_"] (toString (builtins.tail folders))
      else (recurse (builtins.tail folders));
  in recurse (lib.splitString "/" (builtins.toString location))
