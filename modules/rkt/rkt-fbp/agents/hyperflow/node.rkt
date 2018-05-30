#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  ; Entry point
  (node "model" ${hyperflow.node.model})
  ; Edit panel
  ; display
  (node "vp" ${gui.vertical-panel})
  (node "code" ${gui.text-field})
  (node "eval" ${gui.text-field})
  (edge "code" "out" _ "vp" "place" 1)
  (edge "eval" "out" _ "vp" "place" 2)

  ; logic
  ;   code
  ;   update-code
  (node "file-open" ${IO.file.open})
  (edge "model" "compute" 'update-code "file-open" "in" _)
  (edge "file-open" "out" _ "model" "compute" 'update-code)
  (node "exec" ${hyperflow.node.exec})
  (edge "model" "compute" 'exec "exec" "in" _)
  (edge "exec" "out" _ "model" "compute" 'exec)
  ;    change the code widget
  (edge "model" "code" _ "code" "in" _)
  ;   eval
  (edge "model" "eval" _ "eval" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "vp" "out" "out")
  )
