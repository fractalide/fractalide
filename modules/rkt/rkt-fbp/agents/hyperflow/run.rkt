#lang racket

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "frame" ${gui.frame})
   ; VP
   (node "node" ${hyperflow.node})
   (edge "node" "out" _ "frame" "in" _)
   (mesg "node" "in" '(init . "/home/denis/macro-node.rkt"))
   ))
