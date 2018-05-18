#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input-array '("in") ; in array port
    #:output '("out") ; out port
    #:proc
    (lambda (input output input-array output-array)
      (define sum (for/fold ([sum 0])
                            ([(k v) (input-array "in")])
                    (+ sum (recv v))))
      (send (output "out") sum))))
