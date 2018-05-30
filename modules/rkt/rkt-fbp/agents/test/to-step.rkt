#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out")
  (fun
    (let* ([msg (recv (input "in"))]
           [step (string->number (cdr msg))]
           [step (or step 1)])
      (send (output "out") step))))
