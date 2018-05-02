#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (define-agent
              #:input '("add" "sub")
              #:output '("out")
              #:proc (lambda (input output input-array output-array option)
                       (let* ([add (try-recv (input "add"))]
                              [sub (try-recv (input "sub"))]
                              [try-acc (try-recv (input "acc"))]
                              ; Initial
                              [acc (if try-acc try-acc 0)]
                              ; Add?
                              [add-acc (if add (+ 1 acc) acc)]
                              [sub-acc (if sub (- add-acc 1) add-acc)])
                         (send (output "out") (vector "set-label" (string-append "counter : " (number->string sub-acc))))
                         (send (output "acc") sub-acc)))))
