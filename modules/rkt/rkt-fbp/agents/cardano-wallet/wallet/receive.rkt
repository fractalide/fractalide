#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "model" ${cardano-wallet.wallet.receive.model})
  (edge-in "in" "model" "in")
  (edge "model" "out" _ "vp" "place" 40)

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Receive"))))

  (node "lede" ${gui.message})
  (edge "lede" "out" _ "vp" "place" 20)
  (mesg "lede" "in"
        `(init . ((label . ,(string-join
           '("Share this wallet address to receive payments. To protect your privacy, new addresses are generated\n"
             "automatically once you use them."))))))

  (node "address" ${cardano-wallet.wallet.receive.receive-address})
  (edge "address" "out" _ "vp" "place" 30)
  (edge "model" "build" _ "address" "build" _)
  )
