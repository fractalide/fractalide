#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-in "in" "vp" "in")
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 2)
  (mesg "headline" "in" '(init . ((label . "Summary"))))

  (node "hbalance" ${gui.message})
  (edge "hbalance" "out" _ "vp" "place" 3)
  (mesg "hbalance" "in" '(init . ((label . "Balance : "))))
  (node "balance" ${gui.message})
  (edge "balance" "out" _ "vp" "place" 4)
  (mesg "balance" "in" '(init . ((label . ""))))
  (edge-in "balance" "balance" "in")
)
