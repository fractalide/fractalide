#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("add" "sub")
  #:output '("out")
  (fun
    (let* ([add (try-recv (input "add"))]
           [sub (try-recv (input "sub"))]
           [try-acc (try-recv (input "acc"))]
           ; Initial
           [acc (if try-acc try-acc 0)]
           ; Add?
           [add-acc (if add (+ 1 acc) acc)]
           [sub-acc (if sub (- add-acc 1) add-acc)])
      (send (output "out") (cons 'set-label (string-append "counter : " (number->string sub-acc))))
      (send (output "acc") sub-acc))))
