#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph (list
                       (add-agent "nand" "math/nand")
                       (add-agent "clone" "clone")
                       (connect "clone" "out" "1" "nand" "x" #f)
                       (connect "clone" "out" "2" "nand" "y" #f)
                       (virtual-in "in" "clone" "in")
                       (virtual-out "res" "nand" "res"))))
