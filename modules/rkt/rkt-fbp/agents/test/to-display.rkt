#lang racket/base

(provide agt)

(require racket/match
         fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input '("in")
    #:output-array '("out")
    #:proc
    (lambda (input output input-array output-array)
      (let* ([msg (recv (input "in"))])
        (match-define (cons 'choice num) msg)
        (send (hash-ref (output-array "out") num) (cons 'display #t))
        ))))
