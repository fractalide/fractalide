#lang racket/base

(require racket/match
         fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output-array '("out")
    (let* ([msg (recv (input "in"))])
      (match-define (cons 'choice num) msg)
      (send (hash-ref (output-array "out") num) (cons 'display #t))))
