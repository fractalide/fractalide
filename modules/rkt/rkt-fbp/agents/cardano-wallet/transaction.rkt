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
  (edge-in "time" "time" "in")

  (node "details-button" ${gui.button})
  (edge "details-button" "out" _ "right" "place" 70)
  (mesg "details-button" "in" '(init . ((label . "Details"))))

  (node "details-toggle" ${plumbing.cycle-transform})
  (mesg "details-toggle" "option" (list (lambda (_) (list* "details" 'display #t))
                                        (lambda (_) (list* "no-details" 'display #t))))
  (edge "details-button" "out" 'button "details-toggle" "in" _)

  (node "details-choice" ${plumbing.mux})
  (edge "details-toggle" "out" _ "details-choice" "in" _)

  (node "maybe-details" ${gui.place-holder})
  (edge "maybe-details" "out" _ "right" "place" 80)

  (node "no-details" ${gui.vertical-panel})
  (edge "no-details" "out" _ "maybe-details" "place" 10)
  (edge "details-choice" "out" "no-details" "no-details" "in" _)
  (mesg "no-details" "in" '(display . #t))

  (node "details" ${gui.vertical-panel})
  (edge "details" "out" _ "maybe-details" "place" 20)
  (edge "details-choice" "out" "details" "details" "in" _)

  (node "from-label" ${gui.message})
  (edge "from-label" "out" _ "details" "place" 10)
  (mesg "from-label" "in" '(init . ((label . "From address"))))
  
  (node "from" ${gui.message})
  (edge "from" "out" _ "details" "place" 20)
  (edge-in "from" "from" "in")

  (node "to-label" ${gui.message})
  (edge "to-label" "out" _ "details" "place" 30)
  (mesg "to-label" "in" '(init . ((label . "To address"))))
  
  (node "to" ${gui.message})
  (edge "to" "out" _ "details" "place" 40)
  (edge-in "to" "to" "in"))
