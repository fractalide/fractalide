#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (with-node-name "vp" (node ${gui.vertical-panel})
                       (edge-out "out" "out")
                       (edge-in "in" "in"))

  (with-node-name "headline" (node ${gui.message})
                  (edge "out" "vp" "place" #:selection 10)
                  (mesg "in" '(init . ((label .  "Send")))))

  (with-node-name "receiver-label" (node ${gui.message})
                  (edge "out" "vp" "place" #:selection 20)
                  (mesg "in" '(init . ((label .  "Receiver wallet address")))))

  (with-node-name "receiver" (node ${gui.text-field})
                  (edge "out" "vp" "place" #:selection 30)
                  (mesg "in" '(init . ((display . #t)))))

  (with-node-name "amount-label" (node ${gui.message})
                  (edge "out" "vp" "place" #:selection 40)
                  (mesg "in" '(init . ((label .  "Amount")))))

  (with-node-name "amount" (node ${gui.text-field})
                  (edge "out" "vp" "place" #:selection 50)
                  (mesg "in" '(init . ((display . #t)))))

  (with-node-name "next-button" (node ${gui.button})
                  (edge "out" "vp" "place" #:selection 60)
                  (mesg "in" '(init . ((label . "Next"))))))
