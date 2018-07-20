#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Wallet settings"))))

  (node "name-label" ${gui.message})
  (edge "name-label" "out" _ "vp" "place" 20)
  (mesg "name-label" "in" '(init . ((label . "Name"))))

  (node "name" ${gui.text-field})
  (edge "name" "out" _ "vp" "place" 30)
  (mesg "name" "in" '(init . ((label . ""))))

  (node "name-in" ${plumbing.option-transform})
  (mesg "name-in" "option" (lambda (x) (cons 'set-value x)))
  (edge "name-in" "out" _ "name" "in" _)
  (edge-in "name" "name-in" "in")

  (node "name-out" ${plumbing.option-transform})
  (mesg "name-out" "option" cdr)
  (edge "name" "out" 'text-field-enter "name-out" "in" _)
  (edge-out "name-out" "out" "name"))
