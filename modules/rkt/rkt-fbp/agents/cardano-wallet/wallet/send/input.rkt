#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 2)
  (mesg "headline" "in" '(init . ((label . "Send"))))

  (node "receiver" ${gui.text-field})
  (edge "receiver" "out" _ "vp" "place" 3)
  (mesg "receiver" "in" '(init . ((label . "Receiver wallet address"))))

  (node "amount" ${gui.text-field})
  (edge "amount" "out" _ "vp" "place" 4)
  (mesg "amount" "in" '(init . ((label . "Amount"))))

  (node "next" ${gui.button})
  (edge "next" "out" _ "vp" "place" 5)
  (mesg "next" "in" '(init . ((label . "Next"))))
  (node "to-next" ${mesg.set-mesg})
  (edge-out "to-next" "out" "next")
  (edge "next" "out" 'button "to-next" "in" _)
  (mesg "to-next" "option" '(display . #t))
)
