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
   ;    change the code widget
   (edge "model" "code" _ "code" "in" _)
   ;   eval
   (edge "model" "eval" _ "eval" "in" _)

   ; Option panel
   (node "vp-option" ${gui.vertical-panel})
   (edge "vp-option" "out" _ "hp" "place" 0)
   ; The buttons
   (node "hp-option" ${gui.horizontal-panel})
   (edge "hp-option" "out" _ "vp-option" "place" 0)
   (node "but-os-deps" ${gui.button})
   (edge "but-os-deps" "out" _ "hp-option" "place" 0)
   (mesg "but-os-deps" "in" '(init . ((label . "os-deps"))))
   (node "but-modules" ${gui.button})
   (edge "but-modules" "out" _ "hp-option" "place" 1)
   (mesg "but-modules" "in" '(init . ((label . "modules"))))
   ; The place-holder
   (node "option" ${gui.place-holder})
   (edge "option" "out" _ "vp-option" "place" 1)
   ;  Os-deps
   (node "os-deps" ${hyperflow.node.deps})
   (edge "os-deps" "out" _ "option" "place" 1)
   (mesg "os-deps" "option" 'add-os-deps)
   (edge "model" "os-deps" _ "os-deps" "in" _)
   (edge "os-deps" "out" 'add-os-deps "model" "in" _)
   (edge "os-deps" "out" 'remove-os-deps "model" "in" _)
   ;  Modules
   (node "modules" ${hyperflow.node.deps})
   (edge "modules" "out" _ "option" "place" 2)
   (mesg "modules" "option" 'add-modules)
   (edge "model" "modules" _ "modules" "in" _)
   (edge "modules" "out" 'add-modules "model" "in" _)
   (edge "modules" "out" 'remove-modules "model" "in" _)

   ; logic of display in ph
   (mesg "os-deps" "in" '(display . #t))
   (edge "but-os-deps" "out" 'button "to-display-os-deps" "in" _)
   (edge "but-modules" "out" 'button "to-display-modules" "in" _)
   (node "to-display-os-deps" ${mesg.set-ip})
   (node "to-display-modules" ${mesg.set-ip})
   (mesg "to-display-os-deps" "option" '(display . #t))
   (mesg "to-display-modules" "option" '(display . #t))
   (edge "to-display-os-deps" "out" _ "os-deps" "in" _)
   (edge "to-display-modules" "out" _ "modules" "in" _)


   (edge-in "in" "model" "in")
   (edge-out "hp" "out" "out")
   ))
