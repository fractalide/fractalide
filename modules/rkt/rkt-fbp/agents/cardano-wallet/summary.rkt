#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "wallet" ${cardano-wallet.wallet})
  (mesg "wallet" "label" '(init . ((label . "My first wallet"))))
  (mesg "wallet" "balance" '(init . ((label . "70.000000 ADA"))))
  (mesg "wallet" "numtransactions" '(init . ((label . "2"))))
  (mesg "wallet" "in" '(display . #t))
  (edge-out "wallet" "out" "out")
  (edge-in "in" "wallet" "in")

  (node "transaction-1" ${cardano-wallet.transaction})
  (edge "transaction-1" "out" _ "wallet" "transactions-place" 10)
  (mesg "transaction-1" "headline" '(init . ((label . "ADA Received"))))
  (mesg "transaction-1" "amount" '(init . ((label . "50.000000 ADA"))))
  (mesg "transaction-1" "confirmations" '(init . ((label . "High; 26 confirmations"))))
  (mesg "transaction-1" "id" '(init . ((label . "deadbeef"))))
  (mesg "transaction-1" "time" '(init . ((label . "2018-05-27 09:23:12"))))
  (mesg "transaction-1" "from" '(init . ((label . "12345678"))))
  (mesg "transaction-1" "to" '(init . ((label . "87654321"))))

  (node "transaction-2" ${cardano-wallet.transaction})
  (edge "transaction-2" "out" _ "wallet" "transactions-place" 20)
  (mesg "transaction-2" "headline" '(init . ((label . "ADA Received"))))
  (mesg "transaction-2" "amount" '(init . ((label . "20.000000 ADA"))))
  (mesg "transaction-2" "confirmations" '(init . ((label . "High; 25 confirmations"))))
  (mesg "transaction-2" "id" '(init . ((label . "0badc0de"))))
  (mesg "transaction-2" "time" '(init . ((label . "2018-05-26 11:20:12"))))
  (mesg "transaction-2" "from" '(init . ((label . "23456789"))))
  (mesg "transaction-2" "to" '(init . ((label . "87654321")))))
