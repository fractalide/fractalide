#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "clone" ${clone})
  (node "not" ${math.not})
  (node "and1" ${math.and})
  (node "and2" ${math.and})
  (node "or" ${math.or})

  (edge-in "sel" "clone" "in")
  (edge "clone" "out" 1 "not" "in" _)
  (edge "not" "out" _ "and1" "a" _)
  (edge-in "a" "and1" "b")
  (edge "clone" "out" 2 "and2" "a" _)
  (edge-in "b" "and2" "b")
  (edge "and1" "out" _ "or" "a" _)
  (edge "and2" "out" _ "or" "b" _)

  (edge-out "or" "out" "out"))
