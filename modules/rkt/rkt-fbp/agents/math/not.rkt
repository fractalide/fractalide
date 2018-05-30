#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (edge-in "in" "clone" "in")
  (node "clone" ${clone})
  (node "nand" ${math.nand})
  (edge "clone" "out" "1" "nand" "a" _)
  (edge "clone" "out" "2" "nand" "b" _)
  (edge-out "nand" "out" "out"))
