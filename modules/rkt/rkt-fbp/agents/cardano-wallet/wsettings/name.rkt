#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "name-label" ${gui.message})
  (edge "name-label" "out" _ "vp" "place" 20)
  (mesg "name-label" "in" '(init . ((label . "Name"))))

  (node "tf" ${gui.text-field})
  (edge "tf" "out" _ "vp" "place" 30)
  (mesg "tf" "in" '(init . ((label . ""))))

  (node "in" ${plumbing.option-transform})
  (mesg "in" "option" (curry cons 'set-value))
  (edge "in" "out" _ "tf" "in" _)
  (edge-in "name" "in" "in")

  (node "out" ${plumbing.option-transform})
  (mesg "out" "option" cdr)
  (edge "tf" "out" 'text-field-enter "out" "in" _)
  (edge-out "out" "out" "name"))
