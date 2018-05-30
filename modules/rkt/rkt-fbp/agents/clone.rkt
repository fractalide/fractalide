#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in port
  #:output-array '("out") ; out array port
  (fun
   (let* ([msg (recv (input "in"))])
     (for ([(k v) (output-array "out")])
       (send v msg)))))
