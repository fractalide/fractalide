#lang racket

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "not1" "${math.not}")
   (node "not2" "${math.not}")
   (node "nand" "${math.nand}")
   (graph-in "a" "not1" "in")
   (graph-in "b" "not2" "in")
   (edge "not1" "out" _ "nand" "a" _)
   (edge "not2" "out" _ "nand" "b" _)
   (graph-out "nand" "out" "out")))
