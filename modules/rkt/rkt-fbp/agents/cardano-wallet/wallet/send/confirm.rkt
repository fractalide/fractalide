#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Send"))))

  (node "receiver" ${gui.message})
  (edge "receiver" "out" _ "vp" "place" 3)
  (mesg "receiver" "in" '(init . ((label . "To"))))
  (node "address" ${gui.message})
  (edge "address" "out" _ "vp" "place" 4)
  (mesg "address" "in" '(init . ((label . "."))))

  (node "amount" ${gui.message})
  (edge "amount" "out" _ "vp" "place" 5)
  (mesg "amount" "in" '(init . ((label . "Amount"))))
  (node "amt" ${gui.message})
  (edge "amt" "out" _ "vp" "place" 6)
  (mesg "amt" "in" '(init . ((label . "."))))
  (node "fee" ${gui.message})
  (edge "fee" "out" _ "vp" "place" 7)
  (mesg "fee" "in" '(init . ((label . "fee"))))
  (node "fee-amt" ${gui.message})
  (edge "fee-amt" "out" _ "vp" "place" 8)
  (mesg "fee-amt" "in" '(init . ((label . "."))))
  (node "total" ${gui.message})
  (edge "total" "out" _ "vp" "place" 9)
  (mesg "total" "in" '(init . ((label . "total"))))
  (node "total-amt" ${gui.message})
  (edge "total-amt" "out" _ "vp" "place" 10)
  (mesg "total-amt" "in" '(init . ((label . "."))))


  (node "next" ${gui.button})
  (edge "next" "out" _ "vp" "place" 11)
  (mesg "next" "in" '(init . ((label . "Next"))))
)
