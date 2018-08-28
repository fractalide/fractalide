#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.node.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  ; Draw
  (node "pb" ${gui.snip.pasteboard})
  (edge "pb" "out" _ "out" "in" _)
  (edge "model" "pb" _ "pb" "in" _)
  (edge "pb" "out" 'move-to "model" "in" _)
  (edge "pb" "out" 'right-down "model" "in" _)
  (edge "pb" "out" 'is-deleted "model" "in" _)
  (edge "pb" "out" 'select "model" "in" _)
  ; Circle
  (node "circle" ${gui.snip.image})
  (edge "circle" "out" _ "pb" "snip" 0)
  (mesg "circle" "in" (cons 'init (vector 0 0 "./circle.png")))
  ; Text
  (node "text" ${gui.snip.string})
  (edge "text" "out" _ "pb" "snip" 1)
  (edge "model" "text" _ "text" "in" _)
  (node "drop" ${mesg.drop})
  (edge "text" "out" 'is-deleted "drop" "in" _)

  ; Path
  (node "get-path" ${fvm.get-path})
  (edge "model" "get-path" _ "get-path" "in" _)
  (edge "get-path" "out" _ "model" "get-path" _)

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
