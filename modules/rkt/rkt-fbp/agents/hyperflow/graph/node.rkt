#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.node.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  (node "circle" ${gui.snip.image})
  (edge "circle" "out" _ "out" "in" _)
  (edge "model" "circle" _ "circle" "in" _)
  (edge "circle" "out" 'move-to "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "out" "out" "out")
  (edge-out "model" "line-start" "line-start")
  (edge-out "model" "line-end" "line-end")

  (edge "circle" "out" 'right-down "model" "in" _)
  (edge "circle" "out" 'is-deleted "model" "in" _))
