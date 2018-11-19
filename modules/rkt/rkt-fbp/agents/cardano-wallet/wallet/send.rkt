#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "hp" ${gui.horizontal-panel})
  (edge-out "hp" "out" "out")
  (edge-in "in" "hp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "hp" "place" 2)
  (mesg "headline" "in" '(init . ((label . "Send"))))
)
