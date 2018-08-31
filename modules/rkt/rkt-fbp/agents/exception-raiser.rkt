#!/usr/bin/env racket
#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")

  (define msg (or (try-recv (input "option")) "mistakes were made"))

  (recv (input "in"))
  (error msg))

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/graph)
  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)
                                (mesg "main" "in" #t)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
