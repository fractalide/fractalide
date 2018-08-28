#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "model" ${hyperflow.graph.model})

  ; Menu
  (node "menu-file" ${gui.menu})
  (mesg "menu-file" "option" "Graph")
  (mesg "menu-file" "in" #t)
  (node "menu-open" ${gui.menu-item})
  (edge "menu-open" "out" _ "menu-file" "place" 1)
  (mesg "menu-open" "option" (cons 'open-graph #t))
  (mesg "menu-open" "in" '(init . ((label . "open")
                                   (shortcut . #\o))))
  ; Open a file
  (node "load" ${hyperflow.graph.loader})
  (node "get-file" ${gui.get-file})
  (node "get-graph" ${fvm.get-graph})
  (edge "menu-open" "out" 'open-graph "get-file" "in" _)
  (node "in-agent" ${hyperflow.graph.in-agent})
  (edge "get-file" "out" _ "in-agent" "in" _)
  (edge "in-agent" "out" _ "get-graph" "in" _)
  (edge "get-graph" "out" _ "load" "in" _)
  (edge "load" "out" _ "model" "in" _)

  (edge-in "in" "model" "in")
  (edge-out "model" "out" "out")
  (edge-out "menu-file" "out" "menu")
  )
