#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Summary"))))

  (node "state" ${gui.vertical-panel})
  (edge "state" "out" _ "vp" "place" 20)

  (node "label" ${gui.message})
  (edge "label" "out" _ "state" "place" 10)
  (edge-in "label" "label" "in")

  (node "balance" ${gui.message})
  (edge "balance" "out" _ "state" "place" 20)
  (edge-in "balance" "balance" "in")

  (node "numtxshp" ${gui.horizontal-panel})
  (edge "numtxshp" "out" _ "state" "place" 30)

  (node "numtxslabel" ${gui.message})
  (edge "numtxslabel" "out" _ "numtxshp" "place" 10)
  (mesg "numtxslabel" "in" '(init . ((label . "Number of transactions: "))))

  (node "numtransactions" ${gui.message})
  (edge "numtransactions" "out" _ "numtxshp" "place" 20)
  (edge-in "numtransactions" "numtransactions" "in"))
