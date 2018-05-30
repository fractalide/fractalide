#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  ; HP
  (node "hp" "${gui.horizontal-panel}")
  (edge-out "hp" "out" "out")
  ; Msg, button, ...
  (node "add" "${gui.button}")
  (node "sub" "${gui.button}")
  (node "msg" "${gui.message}")
  (edge "sub" "out" _ "hp" "place" 1)
  (edge "msg" "out" _ "hp" "place" 2)
  (edge "add" "out" _ "hp" "place" 3)
  (mesg "add" "in" '(init . ((label . "Add"))))
  (mesg "sub" "in" '(init . ((label . "Sub"))))
  (mesg "msg" "in" '(init . ((label . "No yet started")
                             (auto-resize . #f))))
  ; Model
  (node "model" "${test.counter.model}")
  (edge "model" "out" _ "msg" "in" _)
  (edge "add" "out" 'button "model" "add" _)
  (edge "sub" "out" 'button "model" "sub" _)
  ; Virtual in for the card paradigm
  (edge-in "in" "hp" "in")
  )
