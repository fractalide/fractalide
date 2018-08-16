#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "hp" ${gui.horizontal-panel})
  (mesg "hp" "in" (cons 'set-stretchable-height #f))
  (node "model" ${hyperflow.graph.node.config.model})
  (edge "model" "out" _ "hp" "in" _)

  (node "name" ${gui.text-field})
  (edge "name" "out" _ "hp" "place" 1)
  (edge "model" "name" _ "name" "in" _)
  (edge "name" "out" 'text-field "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "hp" "out" "out"))
