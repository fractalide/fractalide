#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "nand" ${math.nand})
  (node "not" ${math.not})
  (edge-in "a" "nand" "a")
  (edge-in "b" "nand" "b")
  (edge "nand" "out" _ "not" "in" _)
  (edge-out "not" "out" "out"))
