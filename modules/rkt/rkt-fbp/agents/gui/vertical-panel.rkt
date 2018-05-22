#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "panel" "${gui.horizontal-panel}")
   (mesg "panel" "in" (cons 'set-orientation #f))
   (edge-in "in" "panel" "in")
   (edge-in "place" "panel" "place")
   (edge-out "panel" "out" "out")))
