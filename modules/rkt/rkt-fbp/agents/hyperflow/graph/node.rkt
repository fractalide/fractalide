#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.node.model})

  (node "circle" ${gui.snip.image})
  (edge "model" "circle" _ "circle" "in" _)
  (edge "circle" "out" 'move-to "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "circle" "out" "out")
  (edge-out "model" "line-start" "line-start")
  (edge-out "model" "line-end" "line-end")
   )
