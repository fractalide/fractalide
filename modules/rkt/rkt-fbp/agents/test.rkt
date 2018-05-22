#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "nand" ${math.nand})
   (node "and" ${math.and})
   (node "disp" ${displayer})
   (edge "and" "out" _ "disp" "in" _)
   (edge "nand" "out" _ "and" "in" _)
   (mesg "nand" "a" #f)
   (mesg "nand" "b" #t)))
