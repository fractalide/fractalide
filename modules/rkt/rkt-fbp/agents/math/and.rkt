#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "nand" "${math.nand}")
   (node "not" "${math.not}")
   (graph-in "a" "nand" "a")
   (graph-in "b" "nand" "b")
   (edge "nand" "out" _ "not" "in" _)
   (graph-out "out" "not" "out")))

