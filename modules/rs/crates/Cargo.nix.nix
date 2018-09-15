{ pkgs ? import <nixpkgs> {}
, srcs ? pkgs.callPackage ./srcs.nix {}
}:

let
  inherit (pkgs) runCommand;
  names = builtins.attrNames srcs.vals;
  replaceAwk = builtins.toFile "replace.awk" ''
    {
      pad = ""
      if(NF >= 3) {
        match($0, "^([[:space:]]*)")
        pad = substr($0,RSTART,RLENGTH)
        $3 = gensub(ENVIRON["replace"] "(.*);", "\"" ENVIRON["replaceWith"] "\\1\";", 1, $3)
      }
      print pad $0
    }
  '';
  replace-paths = cargoNix: names: if names == [] then cargoNix else let
    name = builtins.head names;
    next-cargoNix = runCommand "Cargo.nix" {
      buildInputs = [ pkgs.gawk ];
      inherit cargoNix replaceAwk;
      replace = srcs.vals."${name}";
      replaceWith = ''''${'' + srcs.strs."${name}" + "}";
    } ''
      gawk -f $replaceAwk < $cargoNix > $out
    '';
    in replace-paths next-cargoNix (builtins.tail names);
in

replace-paths ./Cargo.nix names
