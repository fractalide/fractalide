#lang racket

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "gate" "${math.and}")
   (node "disp" "${displayer}")
   (edge "gate" "out" _ "disp" "in" _)
   (mesg "gate" "a" #t)
   (mesg "gate" "b" #t)
   ))
