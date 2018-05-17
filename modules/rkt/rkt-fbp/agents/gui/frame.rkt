#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
   (node "frame" "gui/frame/frame")
   ; For halting
   (node "halt" "halter")
   (edge "frame" "halt" #f "halt" "in" #f)
   (mesg "halt" "in" #f)
   ; The FVM for dynamic UI
   (node "fvm" "fvm")
   (edge "frame" "fvm" #f "fvm" "in" #f)
   ; Virtual
   (virtual-in "in" "frame" "in")
   (virtual-out "out" "frame" "out")))
