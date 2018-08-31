#!/usr/bin/env racket
#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})

  (node "menu" ${cardano-wallet.menu})
  (edge "menu" "out" _ "frame" "in" _)

  (node "app" ${gui.horizontal-panel})
  (edge "app" "out" _ "frame" "in" _)

  (node "sidebar" ${cardano-wallet.sidebar})
  (edge "sidebar" "out" _ "app" "place" 10)

  (node "stack" ${gui.place-holder})
  (edge "stack" "out" _ "app" "place" 20)

  (node "welcome" ${cardano-wallet.welcome})
  (edge "welcome" "out" _ "stack" "place" 10)

  (node "summary" ${cardano-wallet.summary})
  (edge "summary" "out" _ "stack" "place" 20)

  (node "wsettings" ${cardano-wallet.wsettings})
  (edge "wsettings" "out" _ "stack" "place" 30)
  (edge "sidebar" "data" "wallet-name" "wsettings" "name" _)

  (node "display-assurance-level" ${displayer})
  (mesg "display-assurance-level" "option" "display-assurance-level: ")
  (edge "wsettings" "assurance-level" _ "display-assurance-level" "in" _)
  (mesg "wsettings" "assurance-level" "Medium")

  (edge "wsettings" "name" _ "sidebar" "data" "wallet-name")
  (edge "wsettings" "delete" _ "sidebar" "data" "delete")

  (with-node-name "send" (node ${cardano-wallet.send})
                         (edge "out" "stack" "place" #:selection 35))

  (node "receive" ${cardano-wallet.receive})
  (edge "receive" "out" _ "stack" "place" 40)

  (node "card-display" ${plumbing.demux})
  (mesg "card-display" "option"
        (match-lambda [(cons dest _) (list (list* dest 'display #t))]))

  (edge "sidebar" "choice" _ "card-display" "in" _)

  (with-node-name "card-display"
                  (edge "out" #:selection "summary" "summary" "in")
                  (edge "out" #:selection "send" "send" "in")
                  (edge "out" #:selection "receive" "receive" "in")
                  (edge "out" #:selection "wsettings" "wsettings" "in")
                  (edge "out" #:selection "new" "welcome" "in"))

  (mesg "sidebar" "in" '(init . ()))
  (mesg "sidebar" "init" '(#hash((name . "my wallet"))
                           #hash((name . "my other wallet is also a wallet")))))


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
