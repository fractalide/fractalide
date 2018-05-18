#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "panel" "${gui/horizontal-panel}")
   (mesg "panel" "in" (cons 'set-orientation #f))
   (graph-in "in" "panel" "in")
   (graph-in "place" "panel" "place")
   (graph-out "out" "panel" "out")))
