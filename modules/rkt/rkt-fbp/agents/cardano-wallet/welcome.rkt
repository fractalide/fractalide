#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Welcome"))))

  (node "create" ${gui.button})
  (edge "create" "out" _ "vp" "place" 2)
  (mesg "create" "in" '(init . ((label . "&Create a wallet"))))

  (node "restore" ${gui.button})
  (edge "restore" "out" _ "vp" "place" 3)
  (mesg "restore" "in" '(init . ((label . "&Restore a wallet")))))
