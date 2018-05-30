#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         racket/file)

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (fun
    (define _ (recv (input "in")))
    (define msg (recv (input "option")))
    (send (output "out") msg)))
