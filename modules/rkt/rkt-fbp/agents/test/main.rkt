#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           (node "frame" "gui/frame")
           ; VP
           (node "vp" "gui/vertical-panel")
           (edge "vp" "out" #f "frame" "in" #f)
           ; dummy text field
           (node "tf" "gui/text-field")
           (edge "tf" "out" #f "vp" "place" 1)
           (iip "tf" "in" '(init . ((label . "test: "))))
           ; Slider
           (node "slider" "gui/slider")
           (edge "slider" "out" #f "vp" "place" 8)
           (iip "slider" "in" '(init . ((label . "a slider : ")
                                        (min-value . 0)
                                        (max-value . 100))))
           ; dummy check box
           (node "cb" "gui/check-box")
           (edge "cb" "out" #f "vp" "place" 7)
           (iip "cb" "in" (cons 'set-value #t))
           (iip "cb" "in" (cons 'init '((label . "This is a check-box"))))
           ; Quit button
           (node "but-quit" "gui/button")
           (node "ip-to-close" "test/to-close")
           (edge "but-quit" "out" 'button "ip-to-close" "in" #f)
           (edge "but-quit" "out" #f "vp" "place" 2)
           (edge "ip-to-close" "out" #f "frame" "in" #f)
           (iip "but-quit" "in" '(init . ((label . "&Close"))))
           ; HP
           (node "hp" "gui/horizontal-panel")
           (edge "hp" "out" #f "vp" "place" 3)
           ; dynamic
           (node "but-add" "gui/button")
           (edge "but-add" "out" #f "hp" "place" 10)
           (iip "but-add" "in" '(init . ((label . "&add counter"))))
           (node "but-rem" "gui/button")
           (edge "but-rem" "out" #f "hp" "place" 20)
           (iip "but-rem" "in" '(init . ((label . "&remove counter"))))
           (node "dynamic" "test/dynamic")
           (edge "dynamic" "out" #f "vp" "place" 99)
           (iip "dynamic" "option" "test/counter")
           (edge "but-add" "out" 'button "dynamic" "in" #f)
           (node "to-remove" "test/to-remove")
           (edge "but-rem" "out" 'button "to-remove" "in" #f)
           (edge "to-remove" "out" #f "dynamic" "in" #f)
           ))
