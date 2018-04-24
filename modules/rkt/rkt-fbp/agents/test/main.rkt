#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph (list
                       (add-agent "frame" "agents/gui/frame.rkt")
                       ; HP
                       (add-agent "hp" "agents/gui/horizontal-panel.rkt")
                       (connect "hp" "out" #f "frame" "in" #f)
                       ; Msg, button, ...
                       (add-agent "button" "agents/gui/button.rkt")
                       (add-agent "msg" "agents/gui/message.rkt")
                       (add-agent "msg2" "agents/gui/message.rkt")
                       (add-agent "acc" "agents/test/accumulator.rkt")
                       ; For halting
                       (add-agent "halt" "agents/halter.rkt")
                       (connect "frame" "halt" #f "halt" "in" #f)
                       (iip "halt" "in" #f)
                       ; Connect everything
                       (connect "msg" "out" #f "hp" "place" 8)
                       (connect "msg2" "out" #f "hp" "place" 1)
                       (connect "button" "out" #f "hp" "place" 5)
                       (connect "button" "out" "button-clicked" "acc" "in" #f)
                       (connect "acc" "out" #f "msg" "in" #f)
                       (iip "msg" "in" (vector "set-label" "Not yet clicked"))
                       (iip "msg2" "in" (vector "set-label" "please click the button"))
                       (iip "button" "in" (vector "set-label" "Click me!!"))
                       (iip "acc" "acc" 0)
                       ; Quit button
                       (add-agent "but-quit" "agents/gui/button.rkt")
                       (add-agent "ip-to-close" "agents/test/to-close.rkt")
                       (connect "but-quit" "out" "button-clicked" "ip-to-close" "in" #f)
                       (connect "but-quit" "out" #f "frame" "in" #f)
                       (connect "ip-to-close" "out" #f "frame" "in" #f)
                       (iip "but-quit" "in" (vector "set-label" "Close"))
                       )))
