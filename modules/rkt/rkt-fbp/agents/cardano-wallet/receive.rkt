#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Receive"))))

  (node "lede" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 20)
  (mesg "headline" "in"
        `(init . ((label . ,(string-join
           '("Share this wallet address to receive payments. To protect your privacy, new addresses are generated"
             "automatically once you use them."))))))

  (node "address" ${cardano-wallet.receive-address})
  (edge "address" "out" _ "vp" "place" 30)

  (node "used-addresses" ${cardano-wallet.used-addresses})
  (edge "used-addresses" "out" _ "vp" "place" 40))
