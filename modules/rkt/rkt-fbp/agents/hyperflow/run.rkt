#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; Menu
  (node "menu-bar" ${gui.menu-bar})
  (edge "menu-bar" "out" _ "frame" "in" _)

  (node "menu-about" ${gui.menu})
  (edge "menu-about" "out" _ "menu-bar" "place" 2)
  (mesg "menu-about" "in" #t)
  (mesg "menu-about" "option" "About")

  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; node
  (node "node" ${hyperflow.node})
  (edge "node" "out" _ "vp" "place" 1)
  (edge "node" "menu" _ "menu-bar" "place" 1)
  (mesg "node" "in" '(init . ""))
  )
