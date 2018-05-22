#lang racket

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (graph-in "in" "clone" "in")
   (node "clone" "${clone}")
   (node "nand" "${math.nand}")
   (edge "clone" "out" "1" "nand" "a" _)
   (edge "clone" "out" "2" "nand" "b" _)
   (graph-out "nand" "out" "out")))
