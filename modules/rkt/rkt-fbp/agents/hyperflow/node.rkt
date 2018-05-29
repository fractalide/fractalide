#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   ; Entry point
   (node "model" ${hyperflow.node.model})
   ; Exit point
   (node "hp" ${gui.horizontal-panel})
   ; Edit panel
   ; display
   (node "vp" ${gui.vertical-panel})
   (edge "vp" "out" _ "hp" "place" 2)
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

   ; Option panel
   (node "option" ${gui.tab-panel})
   (edge "option" "out" _ "hp" "place" 0)
   ;  Os-deps
   (node "os-deps" ${hyperflow.node.deps})
   (edge "os-deps" "out" _ "option" "place" "1;os-deps")
   (mesg "os-deps" "option" 'add-os-deps)
   (edge "model" "os-deps" _ "os-deps" "in" _)
   (edge "os-deps" "out" 'add-os-deps "model" "in" _)
   (edge "os-deps" "out" 'remove-os-deps "model" "in" _)
   ;  Modules
   (node "modules" ${hyperflow.node.deps})
   (edge "modules" "out" _ "option" "place" "2;modules")
   (mesg "modules" "option" 'add-modules)
   (edge "model" "modules" _ "modules" "in" _)
   (edge "modules" "out" 'add-modules "model" "in" _)
   (edge "modules" "out" 'remove-modules "model" "in" _)
   ; initial display
   (mesg "os-deps" "in" '(display . #t))

   (edge-in "in" "model" "in")
   (edge-out "hp" "out" "out")
   ))
