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

  (node "sidebar" ${cardano-wallet.sidebar})
  (edge "sidebar" "out" _ "app" "place" 10)

  (node "stack" ${gui.place-holder})
  (edge "stack" "out" _ "app" "place" 20)

  (node "welcome" ${cardano-wallet.welcome})
  (edge "welcome" "out" _ "stack" "place" 10)

  (node "summary" ${cardano-wallet.wallet})
  (edge "summary" "out" _ "stack" "place" 20)
  (mesg "summary" "label" '(init . ((label . "My first wallet"))))
  (mesg "summary" "balance" '(init . ((label . "70.000000 ADA"))))
  (mesg "summary" "numtransactions" '(init . ((label . "2"))))
  (mesg "summary" "in" '(display . #t))

  (node "transaction-1" ${cardano-wallet.transaction})
  (edge "transaction-1" "out" _ "summary" "transactions-place" 10)
  (mesg "transaction-1" "headline" '(init . ((label . "ADA Received"))))
  (mesg "transaction-1" "amount" '(init . ((label . "50.000000 ADA"))))
  (mesg "transaction-1" "confirmations" '(init . ((label . "High; 26 confirmations"))))
  (mesg "transaction-1" "id" '(init . ((label . "deadbeef"))))
  (mesg "transaction-1" "time" '(init . ((label . "2018-05-27 09:23:12"))))
  (mesg "transaction-1" "from" '(init . ((label . "12345678"))))
  (mesg "transaction-1" "to" '(init . ((label . "87654321"))))

  (node "transaction-2" ${cardano-wallet.transaction})
  (edge "transaction-2" "out" _ "summary" "transactions-place" 20)
  (mesg "transaction-2" "headline" '(init . ((label . "ADA Received"))))
  (mesg "transaction-2" "amount" '(init . ((label . "20.000000 ADA"))))
  (mesg "transaction-2" "confirmations" '(init . ((label . "High; 25 confirmations"))))
  (mesg "transaction-2" "id" '(init . ((label . "0badc0de"))))
  (mesg "transaction-2" "time" '(init . ((label . "2018-05-26 11:20:12"))))
  (mesg "transaction-2" "from" '(init . ((label . "23456789"))))
  (mesg "transaction-2" "to" '(init . ((label . "87654321"))))

  (node "wsettings" ${cardano-wallet.wsettings})
  (edge "wsettings" "out" _ "stack" "place" 30)
  (edge "sidebar" "data" "wallet-name" "wsettings" "name" _)

  (node "display-assurance-level" ${displayer})
  (mesg "display-assurance-level" "option" "display-assurance-level: ")
  (edge "wsettings" "assurance-level" _ "display-assurance-level" "in" _)
  (mesg "wsettings" "assurance-level" "Medium")

  (node "display-wallet-name" ${displayer})
  (mesg "display-wallet-name" "option" "wallet name: ")
  (edge "wsettings" "name" _ "display-wallet-name" "in" _)

  (node "card-display-in" ${plumbing.option-transform})
  (mesg "card-display-in" "option" (match-lambda [(cons dest _) (list* dest 'display #t)]))

  (node "card-display-out" ${plumbing.demux})
  (edge "card-display-in" "out" _ "card-display-out" "in" _)

  (edge "sidebar" "choice" _ "card-display-in" "in" _)
  (edge "card-display-out" "out" "new" "welcome" "in" _)
  (edge "card-display-out" "out" "summary" "summary" "in" _)
  (edge "card-display-out" "out" "wsettings" "wsettings" "in" _))

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
