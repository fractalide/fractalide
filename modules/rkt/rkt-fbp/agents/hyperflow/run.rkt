#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; Menu
  (node "menu-bar" ${gui.menu-bar})
  (edge "menu-bar" "out" _ "frame" "in" _)

  (node "menu-file" ${gui.menu})
  (edge "menu-file" "out" _ "menu-bar" "place" 1)
  (mesg "menu-file" "in" #t)
  (mesg "menu-file" "option" "File")

  (node "menu-quit" ${gui.menu-item})
  (edge "menu-quit" "out" _ "menu-file" "place" 1)
  (mesg "menu-quit" "option" (cons 'close #t))
  (mesg "menu-quit" "in" '(init . ((label . "quit")
                                   (shortcut . #\q))))

  (node "menu-about" ${gui.menu})
  (edge "menu-about" "out" _ "menu-bar" "place" 3)
  (mesg "menu-about" "in" #t)
  (mesg "menu-about" "option" "About")

  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; node
  ; (node "node" ${hyperflow.node})
  ; (edge "node" "out" _ "vp" "place" 1)
  ; (edge "node" "menu" _ "menu-bar" "place" 2)
  ; (mesg "node" "in" '(init . ""))

  (node "graph" ${hyperflow.graph})
  (edge "graph" "out" _ "vp" "place" 1)
  (mesg "graph" "in" (cons 'init #t))
  )
