#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "hp" ${gui.horizontal-panel})
  (edge-out "hp" "out" "out")
  (edge-in "in" "hp" "in")


  (node "left" ${gui.vertical-panel})
  (edge "left" "out" _ "hp" "place" 10)

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "left" "place" 10)
  (edge-in "headline" "headline" "in")

  (node "amount" ${gui.message})
  (edge "amount" "out" _ "left" "place" 20)
  (edge-in "amount" "amount" "in")


  (node "right" ${gui.vertical-panel})
  (edge "right" "out" _ "hp" "place" 20)

  (node "confirmations-label" ${gui.message})
  (edge "confirmations-label" "out" _ "right" "place" 10)
  (mesg "confirmations-label" "in" '(init . ((label . "Transaction assurance level"))))

  (node "confirmations" ${gui.message})
  (edge "confirmations" "out" _ "right" "place" 20)
  (edge-in "confirmations" "confirmations" "in")

  (node "id-label" ${gui.message})
  (edge "id-label" "out" _ "right" "place" 30)
  (mesg "id-label" "in" '(init . ((label . "Transaction ID"))))

  (node "id" ${gui.message})
  (edge "id" "out" _ "right" "place" 40)
  (edge-in "id" "id" "in")

  (node "time-label" ${gui.message})
  (edge "time-label" "out" _ "right" "place" 50)
  (mesg "time-label" "in" '(init . ((label . "Transaction time"))))

  (node "time" ${gui.message})
  (edge "time" "out" _ "right" "place" 60)
  (edge-in "time" "time" "in"))
