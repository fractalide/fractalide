#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.line.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  (node "line" ${gui.canvas.line})
  (edge "line" "out" _ "out" "in" _)
  (edge "model" "line" _ "line" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "out" "out" "out"))
