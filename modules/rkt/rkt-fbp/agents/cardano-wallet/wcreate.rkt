#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "ph" ${gui.place-holder})
  (edge-out "ph" "out" "out")
  (edge-in "in" "ph" "in")

  (node "input" ${cardano-wallet.wcreate.wallet-input})
  (edge "input" "out" _ "ph" "place" 1)
  (mesg "input" "in" (cons 'display #t))

  (node "recovery" ${cardano-wallet.wcreate.wallet-recovery})
  (edge "recovery" "out" _ "ph" "place" 2)

  (node "phrase" ${cardano-wallet.wcreate.recovery-phrase})
  (edge "phrase" "out" _ "ph" "place" 3)

  (edge "input" "destroy" _ "recovery" "destroy" _)
  (edge "input" "attach" _ "phrase" "attach" _)
  (edge "input" "phrase" _ "phrase" "set-phrase" _)

  (edge "input" "next" _ "recovery" "in" _)
  (edge "recovery" "back" _ "input" "in" _)
  (edge "recovery" "next" _ "phrase" "in" _)
  (edge "phrase" "back" _ "recovery" "in" _)
  (edge "phrase" "finalize" _ "input" "finalize" _)


  )
