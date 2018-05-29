#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   ; Exit point
   (node "vp" ${gui.vertical-panel})
   (edge-out "vp" "out" "out")

   ; Add
   (node "add" ${gui.text-field})
   (edge "add" "out" _ "vp" "place" 1)
   (mesg "add" "in" '(init . ()))

   ; set the correct action
   (node "to-add" ${mesg.set-action})
   (edge-in "option" "to-add" "option")
   (edge "add" "out" 'text-field-enter "to-add" "in" _)
   (edge "to-add" "out" _ "vp" "in" _)

   ; display
   (node "deps" ${hyperflow.growable-vert})
   (edge "deps" "out" _ "vp" "place" 2)
   (edge "deps" "label" _ "add" "in" _)
   (mesg "deps" "option" "${hyperflow.node.deps.line}")
   (edge-in "in" "deps" "in")
   ))
