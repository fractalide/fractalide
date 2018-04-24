#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph (list
                       (add-agent "nand" "math/nand")
                       (add-agent "and" "math/and")
                       (add-agent "disp" "displayer")
                       (connect "and" "res" #f "disp" "in" #f)
                       (connect "nand" "res" #f "and" "in" #f)
                       (connect "nand" "res" #f "disp" "in" #f)
                       (iip "nand" "x" #f)
                       (iip "nand" "y" #t))))
