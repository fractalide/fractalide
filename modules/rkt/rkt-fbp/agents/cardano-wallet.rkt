#!/usr/bin/env racket
#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ;; (node "wcreate" ${cardano-wallet.wcreate})
  ;; (edge "wcreate" "out" _ "frame" "in" _)
  (node "model" ${cardano-wallet.model})
  (edge "model" "out" _ "frame" "in" _)

  (node "test" ${cardano-wallet.temp.add})
  (edge "model" "test" _ "test" "in" _)
  (edge "test" "out" _ "model" "in" _)

  (mesg "model" "in" '(init . #t))

  ; (node "wallet" ${cardano-wallet.wallet})
  ; (edge "wallet" "out" _ "frame" "in" _)
  )

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (define stop? #f)

  (command-line
    #:program "cardano-wallet"
    #:once-each [("--stop") "Set up the window, then immediately quit. Only useful for profiling."
                 (set! stop? #t)]
    #:args args (void))

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph)))
    (when stop? (fvm-sched (msg-mesg "fvm" "in"
      (cons 'add (make-graph (mesg "main-frame" "in" (cons 'close #t))))))))))
