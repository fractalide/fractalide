#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "nand" "${math.nand}")
   (node "clone" "${clone}")
   (edge "clone" "out" "1" "nand" "x" _)
   (edge "clone" "out" "2" "nand" "y" _)
   (graph-in "in" "clone" "in")
   (graph-out "res" "nand" "res")))
