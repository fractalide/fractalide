{ lib }:
location:
  let recurse = folders:
    let folder = builtins.head folders;
    in if folder == "components" || folder == "contracts"
      then builtins.replaceStrings [" "] ["_"] (toString (builtins.tail folders))
      else (recurse (builtins.tail folders));
  in recurse (lib.splitString "/" (builtins.toString location))
