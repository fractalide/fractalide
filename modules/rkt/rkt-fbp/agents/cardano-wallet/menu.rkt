#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "bar" ${gui.menu-bar})
  (edge-out "bar" "out" "out")

  (node "file" ${gui.menu})
  (edge "file" "out" _ "bar" "place" 1)
  (mesg "file" "in" #t)
  (mesg "file" "option" "File")

  (node "quit" ${gui.menu-item})
  (edge "quit" "out" _ "file" "place" 1)
  (mesg "quit" "option" (cons 'close #t))
  (mesg "quit" "in" '(init . ((label . "quit")
                              (shortcut . #\q))))

  (node "about" ${gui.menu})
  (edge "about" "out" _ "bar" "place" 3)
  (mesg "about" "in" #t)
  (mesg "about" "option" "About"))
