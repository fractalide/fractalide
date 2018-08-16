#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.node.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  ; Circle
  (node "circle" ${gui.snip.image})
  (edge "circle" "out" _ "out" "in" _)
  (edge "model" "circle" _ "circle" "in" _)
  (edge "circle" "out" 'move-to "model" "in" _)
  (edge "circle" "out" 'right-down "model" "in" _)
  (edge "circle" "out" 'is-deleted "model" "in" _)
  (edge "circle" "out" 'select "model" "in" _)

  ; Config
  (node "config" ${hyperflow.graph.node.config})
  (edge "model" "config" _ "config" "in" _)
  (edge "config" "out" _ "out" "in" _)
  (edge "config" "out" 'set-name "model" "in" _)
  (edge "config" "out" 'set-type "model" "in" _)

  ; IO
  (edge-in "in" "model" "in")
  (edge-out "out" "out" "out")
  (edge-out "model" "line-start" "line-start")
  (edge-out "model" "line-end" "line-end")
  (edge-out "config" "out" "config")

  )
