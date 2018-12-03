#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "controls" ${gui.vertical-panel})
  (edge-out "controls" "out" "dynamic-out")

  (node "toggle" ${gui.check-box})
  (edge "toggle" "out" _ "controls" "place" 0)
  (mesg "toggle" "in" '(init . ((label . "Please make sure you have access to backup before continuing.\nOtherwise, you will lose all your funds connected to this wallet."))))

  (node "ph-name" ${gui.place-holder})
  (edge "ph-name" "out" _ "controls" "place" 10)

  (node "wallet-name" ${gui.text-field})
  (edge "wallet-name" "out" _ "ph-name" "place" 0)

  (node "buttons" ${gui.horizontal-panel})
  (edge "buttons" "out" _ "controls" "place" 30)

  (node "confirm-button" ${gui.button})
  (edge "confirm-button" "out" _ "buttons" "place" 10)
  (mesg "confirm-button" "in" '(init . ((label . "Delete")
                                        (enabled . #f))))
  (mesg "confirm-button" "option" '(confirm . #t))

  (node "cancel-button" ${gui.button})
  (edge "cancel-button" "out" _ "buttons" "place" 20)
  (mesg "cancel-button" "in" '(init . ((label . "Cancel"))))

  (node "destroy" ${cardano-cli.wallet.destroy})
  )
