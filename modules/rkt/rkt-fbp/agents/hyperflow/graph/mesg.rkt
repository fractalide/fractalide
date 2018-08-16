#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.mesg.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  ; Box
  (node "box" ${gui.snip.image})
  (edge "box" "out" _ "out" "in" _)
  (edge "model" "box" _ "box" "in" _)
  (edge "box" "out" 'move-to "model" "in" _)
  (edge "box" "out" 'right-down "model" "in" _)
  (edge "box" "out" 'is-deleted "model" "in" _)
  (edge "box" "out" 'select "model" "in" _)

  ; Config
  (node "config-hp" ${gui.horizontal-panel})
  (edge-out "config-hp" "out" "config")
  (node "config-mesg" ${gui.text-field})
  (edge "config-mesg" "out" _ "config-hp" "place" 1)
  (node "config-start" ${gui.button})
  (edge "config-start" "out" _ "config-hp" "place" 2)
  (mesg "config-start" "in" '(init . ((label . "Start"))))
  (edge "model" "config" _ "config-mesg" "in" _)
  (edge "config-mesg" "out" 'text-field "model" "in" _)
  (edge "config-start" "out" 'button "model" "in" _)


  ; IO
  (edge-in "in" "model" "in")
  (edge-out "out" "out" "out")
  (edge-out "model" "line-start" "line-start")
  (edge-out "model" "line-end" "line-end")

  )
