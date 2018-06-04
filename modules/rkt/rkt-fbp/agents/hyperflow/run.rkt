#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; Menu
  (node "menu-bar" ${gui.menu-bar})
  (edge "menu-bar" "out" _ "frame" "in" _)
  (node "menu-file" ${gui.menu})
  (edge "menu-file" "out" _ "menu-bar" "place" 1)
  (mesg "menu-file" "option" "File")
  (mesg "menu-file" "in" #t)
  (node "menu-open" ${gui.menu-item})
  (edge "menu-open" "out" _ "menu-file" "place" 1)
  (mesg "menu-open" "in" '(init . ((label . "open"))))
  (node "menu-save" ${gui.menu-item})
  (edge "menu-save" "out" _ "menu-file" "place" 2)
  (mesg "menu-save" "in" '(init . ((label . "save"))))

  (node "m-test" ${gui.menu})
  (edge "m-test" "out" _ "menu-file" "place" 3)
  (mesg "m-test" "option" "Test")
  (mesg "m-test" "in" #t)

  (node "m-open" ${gui.menu-item})
  (edge "m-open" "out" _ "m-test" "place" 1)
  (mesg "m-open" "in" '(init . ((label . "open"))))
  (node "m-save" ${gui.menu-item})
  (edge "m-save" "out" _ "m-test" "place" 2)
  (mesg "m-save" "in" '(init . ((label . "save"))))


  (node "menu-file2" ${gui.menu})
  (edge "menu-file2" "out" _ "menu-bar" "place" 2)
  (mesg "menu-file2" "in" #t)
  (mesg "menu-file2" "option" "About")

  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; path selection
  (node "hp-selec" ${gui.horizontal-panel})
  (edge "hp-selec" "out" _ "vp" "place" 1)
  (mesg "hp-selec" "in" '(set-stretchable-height . #f))
  (node "selec" ${gui.text-field})
  (node "selec-but" ${gui.button})
  (edge "selec" "out" _ "hp-selec" "place" 1)
  (edge "selec-but" "out" _ "hp-selec" "place" 2)
  (mesg "selec" "in" '(init . ((label . "Node path:"))))
  (mesg "selec-but" "in" '(init . ((label . "go"))))
  (mesg "selec-but" "option" '(get-value . update-type))
  (edge "selec-but" "out" 'get-value "selec" "in" _)
  (edge "selec" "out" 'update-type "node" "in" _)
  ; node
  (node "node" ${hyperflow.node})
  (edge "node" "out" _ "vp" "place" 2)
  (mesg "node" "in" '(init . ""))
  )
