#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "nand" "${math.nand}")
   (node "and" "${math.and}")
   (node "disp" "${displayer}")
   (edge "and" "res" _ "disp" "in" _)
   (edge "nand" "res" _ "and" "in" _)
   (edge "nand" "res" _ "disp" "in" _)
   (mesg "nand" "x" #f)
   (mesg "nand" "y" #t)))
