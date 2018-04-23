#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph (list
                       (add-agent "nand" "agents/math/nand.rkt")
                       (add-agent "and" "agents/math/and.rkt")
                       (add-agent "disp" "agents/displayer.rkt")
                       (connect "and" "res" #f "disp" "in" #f)
                       (connect "nand" "res" #f "and" "in" #f)
                       (connect "nand" "res" #f "disp" "in" #f)
                       (iip "nand" "x" #f)
                       (iip "nand" "y" #t))))
