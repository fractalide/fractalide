#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "msg" ${gui.message})
   (edge-out "msg" "out" "out")
   (node "process" ${hyperflow.node.deps.process})
   (edge-in "in" "process" "in")
   (edge "process" "out" _ "msg" "in" _)
   ))
