#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" "${gui.frame.frame}")
  ; For halting
  (node "halt" "${halter}")
  (edge "frame" "halt" _ "halt" "in" _)
  (mesg "halt" "in" #f)
  ; The FVM for dynamic UI
  (node "fvm" "${fvm}")
  (edge "frame" "fvm" _ "fvm" "in" _)
  ; Virtual
  (edge-in "in" "frame" "in")
  (edge-out "frame" "out" "out"))
