#lang racket

(require racket/draw)
(require racket/runtime-path)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-runtime-path fractalide-logo-path "../../../../../pkgs/hyperflow/imgs/fractalide.png")
(define fractalide-logo (read-bitmap fractalide-logo-path))

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 0)
  (mesg "headline" "in" `(init . ((label . ,fractalide-logo))))

  (node "wallets-choice" ${cardano-wallet.wallets-choice})
  (edge "wallets-choice" "out" _ "vp" "place" 5)
  (mesg "wallets-choice" "in" '(init . ()))
  (mesg "wallets-choice" "init" '(#hash((name . "my wallet"))
                                  #hash((name . "my other wallet is also a wallet"))))

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
