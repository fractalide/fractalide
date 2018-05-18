#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input '("in") ; in port
    #:output-array '("out") ; out array port
    #:proc
    (lambda (input output input-array output-array)
      (let* ([msg (recv (input "in"))])
        (for ([(k v) (output-array "out")])
          (send v msg))))))
