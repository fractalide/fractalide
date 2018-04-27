#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           (agent "nand" "math/nand")
           (agent "and" "math/and")
           (agent "disp" "displayer")
           (edge "and" "res" #f "disp" "in" #f)
           (edge "nand" "res" #f "and" "in" #f)
           (edge "nand" "res" #f "disp" "in" #f)
           (iip "nand" "x" #f)
           (iip "nand" "y" #t)))
