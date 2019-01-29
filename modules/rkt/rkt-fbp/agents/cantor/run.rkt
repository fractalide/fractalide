#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cantor.wallet})
(define msg (wallet "real" 'summary '() 'init))
(define-graph
  (node "frame" ${guiv2.frame})

  (node "wallet" ${cantor.wallet.wallet})
  (edge "wallet" "out" _ "frame" "in" _)
  (mesg "wallet" "in" `(wallet . ,msg))
  (edge "wallet" "out" 'wallet "wallet" "in" _)

  (node "receive" ${cantor.wallet.receive})
  (edge "wallet" "receive" _ "receive" "in" _)
  (edge "receive" "out" _ "wallet" "receive" _)
  (node "gen" ${cantor.wallet.generate})
  (edge "receive" "gen" _ "gen" "in" _)
  (edge "gen" "out" _ "wallet" "in" _)
  (node "cli-gen" ${cardano-cli.wallet.address})
  (edge "gen" "passwd" _ "cli-gen" "passwd" _)
  (edge "gen" "name" _ "cli-gen" "name" _)
  (edge "gen" "account-index" _ "cli-gen" "account-index" _)
  (edge "gen" "address-index" _ "cli-gen" "address-index" _)
  (edge "cli-gen" "out" _ "gen" "res" _)

  (node "halt" ${halter})
  (mesg "halt" "in" #t)
  )
