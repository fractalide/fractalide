#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "canvas" ${gui.pasteboard})

  (node "node1" ${hyperflow.graph.node})
  (edge "node1" "out" _ "canvas" "snip" 3)
  (mesg "node1" "in" (cons 'init (vector 200 100 "Hello")))

  (node "node2" ${hyperflow.graph.node})
  (edge "node2" "out" _ "canvas" "snip" 4)
  (mesg "node2" "in" (cons 'init (vector 400 100 "Hello")))

  (node "node3" ${hyperflow.graph.node})
  (edge "node3" "out" _ "canvas" "snip" 5)
  (mesg "node3" "in" (cons 'init (vector 600 100 "Hello")))

  (node "line1" ${hyperflow.graph.line})
  (edge "line1" "out" _ "canvas" "place" 10)
  (mesg "line1" "in" (cons 'init (vector 250 150 450 150)))
  (edge "node1" "line-start" 1 "line1" "in" _)
  (edge "node2" "line-end" 1 "line1" "in" _)

  (node "line2" ${hyperflow.graph.line})
  (edge "line2" "out" _ "canvas" "place" 11)
  (mesg "line2" "in" (cons 'init (vector 450 150 650 150)))
  (edge "node2" "line-start" 1 "line2" "in" _)
  (edge "node3" "line-end" 1 "line2" "in" _)

  (edge-out "canvas" "out" "out")
  )
