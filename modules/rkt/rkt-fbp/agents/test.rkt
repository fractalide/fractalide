#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           (node "nand" "math/nand")
           (node "and" "math/and")
           (node "disp" "displayer")
           (edge "and" "res" #f "disp" "in" #f)
           (edge "nand" "res" #f "and" "in" #f)
           (edge "nand" "res" #f "disp" "in" #f)
           (iip "nand" "x" #f)
           (iip "nand" "y" #t)))
