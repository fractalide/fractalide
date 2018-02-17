#lang typed/racket

(provide write-default-dot-nix)

(: write-default-dot-nix (Path -> Void))
(define (write-default-dot-nix path)
  (with-output-to-file (build-path path "default.nix") #:exists 'replace 
    (λ () (display default-template))))

(define default-template #<<EOM
{
  fractalide ? import <fractalide> {}
  , buffet ? fractalide.buffet
  , rs ? null
  , purs ? null
}:

let
  inherit (buffet.pkgs.lib) attrVals recursiveUpdate;
  inherit (buffet.pkgs) writeTextFile;
  inherit (builtins) head;
  target = if rs != null then { name = "rs"; nodes = newBuffet.nodes.rs; node = rs;}
    else if purs != null then { name = "purs"; nodes = newBuffet.nodes.purs; node = purs;}
    else { name = "rs"; nodes = newBuffet.nodes.rs; node = rs;};
  targetNode = (head (attrVals [target.node] target.nodes));
  newBuffet = {
    nodes = recursiveUpdate buffet.nodes fractalNodes;
    edges = recursiveUpdate buffet.edges fractalEdges;
    support = buffet.support;
    imsg = buffet.imsg;
    mods = recursiveUpdate buffet.mods fractalMods;
    pkgs = buffet.pkgs;
    release = buffet.release;
    verbose = buffet.verbose;
  };
  fractalEdges = import ./edges { buffet = newBuffet; };
  fractalNodes = import ./nodes { buffet = newBuffet; };
  fractalMods  = import ./mods  { buffet = newBuffet; };
  fvm = import (<fractalide> + "/nodes/fvm/${target.name}") { buffet = newBuffet; };
  test = writeTextFile {
    name = targetNode.name;
    text = "${fvm}/bin/fvm ${targetNode}";
    executable = true;
  };
in
{ nodes = fractalNodes; edges = fractalEdges; test = test; service = ./service.nix; mods = fractalMods; }
EOM
  )