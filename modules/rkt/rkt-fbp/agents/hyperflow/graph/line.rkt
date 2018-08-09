#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.line.model})

  (node "line" ${gui.canvas.line})
  (edge "model" "line" _ "line" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "line" "out" "out"))
