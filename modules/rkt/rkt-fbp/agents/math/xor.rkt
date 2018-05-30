#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "clone1" ${clone})
  (node "clone2" ${clone})
  (node "not1" ${math.not})
  (node "not2" ${math.not})
  (node "and1" ${math.and})
  (node "and2" ${math.and})
  (node "or" ${math.or})

  (edge-in "a" "clone1" "in")
  (edge "clone1" "out" 1 "not1" "in" _)
  (edge "clone1" "out" 2 "and2" "a" _)
  (edge "not1" "out" _ "and1" "a" _)
  (edge "and1" "out" _ "or" "a" _)

  (edge-in "b" "clone2" "in")
  (edge "clone2" "out" 2 "not2" "in" _)
  (edge "clone2" "out" 1 "and1" "b" _)
  (edge "not2" "out" _ "and2" "b" _)
  (edge "and2" "out" _ "or" "b" _)

  (edge-out "or" "out" "out"))
