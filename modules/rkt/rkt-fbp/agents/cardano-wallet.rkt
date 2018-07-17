#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; Menu
  (node "menu-bar" ${gui.menu-bar})
  (edge "menu-bar" "out" _ "frame" "in" _)

  (node "menu-file" ${gui.menu})
  (edge "menu-file" "out" _ "menu-bar" "place" 1)
  (mesg "menu-file" "in" #t)
  (mesg "menu-file" "option" "File")

  (node "menu-quit" ${gui.menu-item})
  (edge "menu-quit" "out" _ "menu-file" "place" 1)
  (mesg "menu-quit" "option" (cons 'close #t))
  (mesg "menu-quit" "in" '(init . ((label . "quit")
                                   (shortcut . #\q))))

  (node "menu-about" ${gui.menu})
  (edge "menu-about" "out" _ "menu-bar" "place" 3)
  (mesg "menu-about" "in" #t)
  (mesg "menu-about" "option" "About")

  (node "app" ${gui.horizontal-panel})
  (edge "app" "out" _ "frame" "in" _)

  (node "sidebar" ${cardano-wallet.menu})
  (edge "sidebar" "out" _ "app" "place" 10)

  (node "stack" ${gui.place-holder})
  (edge "stack" "out" _ "app" "place" 20)

  (node "welcome" ${cardano-wallet.welcome})
  (edge "welcome" "out" _ "stack" "place" 10)
  (mesg "welcome" "in" '(display . #t))

  (node "summary" ${cardano-wallet.wallet})
  (edge "summary" "out" _ "stack" "place" 20)
  (mesg "summary" "label" '(init . ((label . "My first wallet"))))
  (mesg "summary" "balance" '(init . ((label . "70.000000 ADA"))))
  (mesg "summary" "numtransactions" '(init . ((label . "2"))))

  (node "card-display-in" ${plumbing.option-transform})
  (mesg "card-display-in" "option" (match-lambda [(cons dest _) (list* dest 'display #t)]))

  (node "card-display-out" ${plumbing.mux})
  (edge "card-display-in" "out" _ "card-display-out" "in" _)

  (edge "sidebar" "choice" _ "card-display-in" "in" _)
  (edge "card-display-out" "out" "new" "welcome" "in" _)
  (edge "card-display-out" "out" "summary" "summary" "in" _))

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
