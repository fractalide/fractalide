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

  (node "type" ${gui.button})
  (edge "type" "out" _ "hp" "place" 2)
  (mesg "type" "in" '(init . ((label . "type"))))
  (node "get-type" ${gui.get-file})
  (edge "type" "out" 'button "get-type" "in" _)
  (node "set-type" ${mesg.put-action})
  (mesg "set-type" "option" 'set-type)
  (edge "get-type" "out" _ "set-type" "in" _)
  (edge "set-type" "out" _ "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "hp" "out" "out"))
