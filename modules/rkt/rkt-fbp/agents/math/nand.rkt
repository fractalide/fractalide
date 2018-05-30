#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("a" "b")
  #:output '("out")
  (fun
   (define a (recv (input "a")))
   (define b (recv (input "b")))
   (send (output "out") (nand a b))))
