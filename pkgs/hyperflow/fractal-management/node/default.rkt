#lang typed/racket

(provide build-node)

(require "../generic/paths.rkt")
(require "../generic/file-handling.rkt")

(: build-node (String String String -> Void))
(define (build-node fractal-name language node-name)
  (define node-path (make-node-path fractal-name language node-name))
  (define default-nix (component-list-default-nix fractal-name "nodes" language))
  (make-directory* node-path)
  (write-node-files node-path)
  (insert-raw-into-default default-nix "RAW NODES" node-name "nodes"))

(: write-node-files (Path -> Void))
(define (write-node-files path)
  (write-file (build-path path "lib.rs") lib-rs)
  (write-file (build-path path "default.nix") default-nix))

(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define lib-rs #<<EOM
#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  input(a: bool, b: bool),
  inarr(test: i32),
  output(output: bool),
  outarr(boum: usize),
  fn run(&mut self) -> Result<Signal> {
    let mut sum = 0;
    for (_id, elem) in &self.inarr.test {
      sum += elem.recv()?;   
    }
    let a = self.input.a.recv()?;
    let b = self.input.b.recv()?;
    let res = ! (a && b);
    self.output.output.send(res)?;
    Ok(End)
  }
}
EOM
  )

(define default-nix #<<EOM
{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [];
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (capnp_0_8_15 {}) ];
  osdeps = with pkgs; [];
}
EOM
  )