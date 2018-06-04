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

  ; Menu
  (node "menu-file" ${gui.menu})
  (mesg "menu-file" "option" "File")
  (mesg "menu-file" "in" #t)
  (node "menu-open" ${gui.menu-item})
  (edge "menu-open" "out" _ "menu-file" "place" 1)
  (mesg "menu-open" "option" (cons 'open-node #t))
  (mesg "menu-open" "in" '(init . ((label . "open"))))
  (node "menu-save" ${gui.menu-item})
  (edge "menu-save" "out" _ "menu-file" "place" 2)
  (mesg "menu-save" "in" '(init . ((label . "save"))))

  ; Open a file
  (node "open" ${gui.get-file})
  (edge "menu-open" "out" 'open-node "open" "in" _)
  (node "set-open-file" ${mesg.put-action})
  (mesg "set-open-file" "option" 'update-type)
  (edge "open" "out" _ "set-open-file" "in" _)
  (edge "set-open-file" "out" _ "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "vp" "out" "out")
  (edge-out "menu-file" "out" "menu")
  )
