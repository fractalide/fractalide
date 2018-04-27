#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           (agent "frame" "gui/frame")
           ; VP
           (agent "vp" "gui/vertical-panel")
           (edge "vp" "out" #f "frame" "in" #f)
           ; HP
           (agent "hp" "gui/horizontal-panel")
           (edge "hp" "out" #f "vp" "place" 2)
           ; Msg, button, ...
           (agent "button" "gui/button")
           (agent "msg" "gui/message")
           (agent "msg2" "gui/message")
           (agent "acc" "test/accumulator")
           ; For halting
           (agent "halt" "halter")
           (edge "frame" "halt" #f "halt" "in" #f)
           (iip "halt" "in" #f)
           ; step
           (agent "step" "gui/text-field")
           (edge "step" "out" #f "vp" "place" 8)
           (iip "step" "in" #t)
           (agent "to-step" "test/to-step")
           (edge "step" "out" 'text-field "to-step" "in" #f)
           (edge "to-step" "out" #f "acc" "option" #f)
           ; Connect everything
           (edge "msg" "out" #f "hp" "place" 8)
           (edge "msg2" "out" #f "hp" "place" 1)
           (edge "button" "out" #f "hp" "place" 5)
           (edge "button" "out" 'button "acc" "in" #f)
           (edge "acc" "out" #f "msg" "in" #f)
           (iip "msg" "in" (vector "set-label" "Not yet clicked"))
           (iip "msg2" "in" (vector "set-label" "please click the button"))
           (iip "button" "in" (vector "set-label" "Click me!!"))
           (iip "acc" "acc" 0)
           ; Quit button
           (agent "but-quit" "gui/button")
           (agent "ip-to-close" "test/to-close")
           (edge "but-quit" "out" 'button "ip-to-close" "in" #f)
           (edge "but-quit" "out" #f "vp" "place" 1)
           (edge "ip-to-close" "out" #f "frame" "in" #f)
           (iip "but-quit" "in" (vector "set-label" "Close"))
           ))
