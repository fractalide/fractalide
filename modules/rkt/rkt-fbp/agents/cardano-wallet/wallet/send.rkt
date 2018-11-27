#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "ph" ${gui.place-holder})
  (edge-out "ph" "out" "out")
  (edge-in "in" "ph" "in")

  (node "input" ${cardano-wallet.wallet.send.input})
  (edge "input" "out" _ "ph" "place" 1)
  (mesg "input" "in" '(display . #t))

  (node "confirm" ${cardano-wallet.wallet.send.confirm})
  (edge "confirm" "out" _ "ph" "place" 2)
  (edge "input" "next" _ "confirm" "in" _)
)
