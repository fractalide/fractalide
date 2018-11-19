#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ;; (node "wcreate" ${cardano-wallet.wcreate})
  ;; (edge "wcreate" "out" _ "frame" "in" _)

  (node "wallet" ${cardano-wallet.wallet})
  (edge "wallet" "out" _ "frame" "in" _)
  )
