#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "not1" ${math.not})
  (node "not2" ${math.not})
  (node "nand" ${math.nand})
  (edge-in "a" "not1" "in")
  (edge-in "b" "not2" "in")
  (edge "not1" "out" _ "nand" "a" _)
  (edge "not2" "out" _ "nand" "b" _)
  (edge-out "nand" "out" "out"))
