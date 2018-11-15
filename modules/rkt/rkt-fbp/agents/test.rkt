#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "disp" ${displayer})
  ;; (node "list" ${cardano-cli.blockchain.list})

  ;; (node "new" ${cardano-cli.blockchain.pull})
  ;; (mesg "new" "name" "testfromracket")

  ;; (edge "new" "out" _ "list" "trigger" _)
  (node "create" ${cardano-cli.wallet.create})
  (edge "create" "out" _ "disp" "in" _)
  (mesg "create" "name" "fromfracta2")
  (mesg "create" "passwd" "fractalide")
  ;; (edge "list" "out" _ "disp" "in" _)
  )
