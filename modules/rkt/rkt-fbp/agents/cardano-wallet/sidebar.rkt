#lang racket

(require racket/draw)
(require racket/runtime-path)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-runtime-path cantor-logo-path "cantor-logo-min.png")
(define cantor-logo (read-bitmap cantor-logo-path))

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 0)
  (mesg "headline" "in" `(init . ((label . ,cantor-logo))))

  (node "wallets-choice" ${cardano-wallet.wallets-choice})
  (edge "wallets-choice" "out" _ "vp" "place" 5)

  (edge-in "in" "wallets-choice" "in")
  (edge-in "init" "wallets-choice" "init")

  (node "wallet-data-in" ${plumbing.mux-demux})
  (mesg "wallet-data-in" "option"
        (match-lambda [(cons "wallet-name" new-name)
                       (list (cons "edit" `#hash((name . ,new-name))))]
                      [(cons "delete" _)
                       (list (cons "delete" #t))]))
  (edge "wallet-data-in" "out" "edit" "wallets-choice" "edit" _)
  (edge "wallet-data-in" "out" "delete" "wallets-choice" "delete" _)
  (edge "wallet-data-in" "out" "init" "wallets-choice" "init" _)
  (edge-in "data" "wallet-data-in" "in")

  (node "wallet-data-out" ${plumbing.demux})
  (mesg "wallet-data-out" "option"
	(lambda (data) (list (cons "wallet-name" (hash-ref data 'name)))))
  (edge "wallets-choice" "choice" _ "wallet-data-out" "in" _)
  (edge-out "wallet-data-out" "out" "data")

  (node "button-pushes" ${plumbing.mux})
  (edge-out "button-pushes" "out" "choice")

  (node "summary" ${gui.button})
  (edge "summary" "out" _ "vp" "place" 10)
  (edge "summary" "out" 'button "button-pushes" "in" "summary")
  (mesg "summary" "in" '(init . ((label . "Summary"))))

  (node "send" ${gui.button})
  (edge "send" "out" _ "vp" "place" 20)
  (edge "send" "out" 'button "button-pushes" "in" "send")
  (mesg "send" "in" '(init . ((label . "Send"))))

  (node "receive" ${gui.button})
  (edge "receive" "out" _ "vp" "place" 30)
  (edge "receive" "out" 'button "button-pushes" "in" "receive")
  (mesg "receive" "in" '(init . ((label . "Receive"))))

  (node "transactions" ${gui.button})
  (edge "transactions" "out" _ "vp" "place" 40)
  (edge "transactions" "out" 'button "button-pushes" "in" "transactions")
  (mesg "transactions" "in" '(init . ((label . "Transactions"))))

  (node "wsettings" ${gui.button})
  (edge "wsettings" "out" _ "vp" "place" 50)
  (edge "wsettings" "out" 'button "button-pushes" "in" "wsettings")
  (mesg "wsettings" "in" '(init . ((label . "Wallet settings"))))

  (node "new" ${gui.button})
  (edge "new" "out" _ "vp" "place" 60)
  (edge "new" "out" 'button "button-pushes" "in" "new")
  (mesg "new" "in" '(init . ((label . "New wallet"))))

  (node "asettings" ${gui.button})
  (edge "asettings" "out" _ "vp" "place" 70)
  (edge "asettings" "out" 'button "button-pushes" "in" "asettings")
  (mesg "asettings" "in" '(init . ((label . "App settings")))))
