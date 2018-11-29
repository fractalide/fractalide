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
