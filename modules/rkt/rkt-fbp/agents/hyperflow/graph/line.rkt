#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.line.model})
  (node "out" ${mesg.action})
  (edge "model" "out" _ "out" "in" _)

  (node "line" ${gui.canvas.line})
  (edge "line" "out" _ "out" "in" _)
  (edge "model" "line" _ "line" "in" _)
  (edge "line" "out" 'left-down "model" "in" _)

  ; Config
  (node "hp" ${gui.horizontal-panel})
  (edge-out "hp" "out" "config")
  (node "outport" ${gui.choice})
  (mesg "outport" "in" '(init . ((label . "From : ")
                                (choices . ("none")))))
  (edge "outport" "out" _ "hp" "place" 1)
  (edge "model" "from" _ "outport" "in" _)
  (edge "outport" "out" 'choice "model" "in" _)

  (node "inport" ${gui.choice})
  (mesg "inport" "in" '(init . ((label . "To : ")
                                (choices . ("none")))))
  (edge "inport" "out" _ "hp" "place" 2)
  (edge "model" "to" _ "inport" "in" _)
  (node "set-inport" ${mesg.set-action})
  (mesg "set-inport" "option" 'choice-outport)
  (edge "inport" "out" 'choice "set-inport" "in" _)
  (edge "set-inport" "out" _ "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "out" "out" "out"))
