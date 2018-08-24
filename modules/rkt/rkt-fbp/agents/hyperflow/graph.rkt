#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.model})

  (node "load" ${hyperflow.graph.loader})
  (node "punk" ${fvm.get-graph})
  (edge "punk" "out" _ "load" "in" _)
  (mesg "punk" "in" (g-agent "" "agents/hyperflow/graph.rkt"))
  (edge "load" "out" _ "model" "in" _)


  (edge-in "in" "model" "in")
  (edge-out "model" "out" "out")
  )
