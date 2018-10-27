(import <nixpkgs> {}).fetchgit
  (builtins.removeAttrs (builtins.fromJSON (builtins.readFile ./default.json)) [ "date" ])
