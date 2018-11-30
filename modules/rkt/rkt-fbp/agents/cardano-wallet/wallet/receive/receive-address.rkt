#lang racket

(require racket/draw)
(require racket/runtime-path)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-runtime-path address-qr-path "./baconipsum.png")
(define address-qr (read-bitmap address-qr-path))

(define-graph
  (node "vp" ${gui.vertical-panel})
  (mesg "vp" "in" '(set-stretchable-height . #f))
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Generated addresses"))))

  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 20)

  (node "qr" ${gui.message})
  (edge "qr" "out" _ "hp" "place" 10)
  (mesg "qr" "in" `(init . ((label . ,address-qr))))

  (node "right" ${gui.vertical-panel})
  (mesg "right" "in" '(set-stretchable-height . #f))
  (edge "right" "out" _ "hp" "place" 20)

  (node "address" ${gui.message})
  (edge "address" "out" _ "right" "place" 10)
  (mesg "address" "in" '(init . ((label . "please fill password"))))

  (node "generate-label" ${gui.message})
  (edge "generate-label" "out" _ "right" "place" 20)
  (mesg "generate-label" "in" '(init . ((label . "Generate new address"))))

  (node "down" ${gui.horizontal-panel})
  (edge "down" "out" _ "right" "place" 30)

  (node "password" ${gui.text-field})
  (edge "password" "out" _ "down" "place" 10)
  (mesg "password" "in" '(init . ((label . "Password")
                                  (style . (single password)))))

  (node "button" ${gui.button})
  (edge "button" "out" _ "down" "place" 20)
  (mesg "button" "in" '(init . ((label . "Generate"))))

  (node "trigger" ${cardano-wallet.wallet.receive.trigger})
  (node "generate" ${cardano-wallet.wallet.receive.generate})
  (edge-in "build" "generate" "option")
  (edge "password" "out" 'text-field "trigger" "option" _)

  ; Manage the click
  (edge "button" "out" 'button "trigger" "in" _)
  (edge "trigger" "out" _ "generate" "passwd" _)
  (edge "trigger" "text-field" _ "password" "in" _)

  (node "cli" ${cardano-cli.wallet.address})
  (edge "generate" "passwd" _ "cli" "passwd" _)
  (edge "generate" "name" _ "cli" "name" _)
  (edge "generate" "account-index" _ "cli" "account-index" _)
  (edge "generate" "address-index" _ "cli" "address-index" _)
  (edge "cli" "out" _ "generate" "res" _)
  (edge "generate" "out" _ "vp" "in" _)
  (edge "generate" "address" _ "address" "in" _)
  (edge "generate" "qr" _ "qr" "in" _)
  )
