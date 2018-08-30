#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input-array '("in") ; in array port
  #:output '("out") ; out port
   (define sum (for/fold ([sum 0])
                         ([(k v) (input-array "in")])
                 (+ sum (recv v))))
   (send (output "out") sum))
