#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.model})

  (edge-in "in" "model" "in")
  (edge-out "model" "out" "out")
  )
