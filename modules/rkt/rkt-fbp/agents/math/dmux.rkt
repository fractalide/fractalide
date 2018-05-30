#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "sel-clone" ${clone})
  (node "in-clone" ${clone})
  (node "not" ${math.not})
  (node "and1" ${math.and})
  (node "and2" ${math.and})

  (edge-in "sel" "sel-clone" "in")
  (edge "sel-clone" "out" 1 "not" "in" _)
  (edge-in "in" "in-clone" "in")
  (edge "not" "out" _ "and1" "a" _)
  (edge "in-clone" "out" 1 "and1" "b" _)
  (edge "sel-clone" "out" 2 "and2" "a" _)
  (edge "in-clone" "out" 2 "and2" "b" _)

  (edge-out "and1" "a" "out")
  (edge-out "and2" "b" "out")
  )
