#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           ; HP
           (node "hp" "gui/horizontal-panel")
           (virtual-out "out" "hp" "out")
           ; Msg, button, ...
           (node "add" "gui/button")
           (node "sub" "gui/button")
           (node "msg" "gui/message")
           (edge "sub" "out" #f "hp" "place" 1)
           (edge "msg" "out" #f "hp" "place" 2)
           (edge "add" "out" #f "hp" "place" 3)
           (iip "add" "in" (vector "set-label" "Add"))
           (iip "sub" "in" (vector "set-label" "Sub"))
           (iip "msg" "in" (vector "set-label" "No yet started"))
           ; Model
           (node "model" "test/counter/model")
           (edge "model" "out" #f "msg" "in" #f)
           (edge "add" "out" 'button "model" "add" #f)
           (edge "sub" "out" 'button "model" "sub" #f)
           ))
