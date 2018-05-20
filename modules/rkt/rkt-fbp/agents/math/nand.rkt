#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input '("a" "b") ; in port
    #:output '("out") ; out port
    #:proc
    (lambda (input output input-array output-array)
      (define a (recv (input "a")))
      (define b (recv (input "b")))
      (send (output "out") (nand a b)))))
