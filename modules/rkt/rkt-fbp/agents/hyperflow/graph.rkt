#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.model})

  (node "load" ${hyperflow.graph.loader})
  (node "get-graph" ${fvm.get-graph})
  (edge "get-graph" "out" _ "load" "in" _)
  (mesg "get-graph" "in" (g-agent "" "agents/hyperflow/graph.rkt"))
  (edge "load" "out" _ "model" "in" _)


  (edge-in "in" "model" "in")
  (edge-out "model" "out" "out")
  )
