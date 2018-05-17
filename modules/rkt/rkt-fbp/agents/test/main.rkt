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
           (mesg "tf" "in" '(init . ((label . "test: "))))
           ; Quit button
           (node "but-quit" "gui/button")
           (node "ip-to-close" "test/to-close")
           (edge "but-quit" "out" 'button "ip-to-close" "in" #f)
           (edge "but-quit" "out" #f "vp" "place" 2)
           (edge "ip-to-close" "out" #f "frame" "in" #f)
           (mesg "but-quit" "in" '(init . ((label . "&Close"))))
           ; dummy check box
           (node "cb" "gui/check-box")
           (edge "cb" "out" #f "vp" "place" 7)
           (mesg "cb" "in" (cons 'set-value #t))
           (mesg "cb" "in" (cons 'init '((label . "This is a check-box"))))
           ; Slider
           (node "slider" "gui/slider")
           (edge "slider" "out" #f "vp" "place" 8)
           (mesg "slider" "in" '(init . ((label . "a slider : ")
                                        (min-value . 0)
                                        (max-value . 100))))
           ; Gauge
           (node "gauge" "gui/gauge")
           (edge "gauge" "out" #f "vp" "place" 9)
           (mesg "gauge" "in" '(init . ((range . 50))))
           (mesg "gauge" "in" '(set-value . 20))
           ; combo-field
           (node "cf" "gui/combo-field")
           (edge "cf" "out" #f "vp" "place" 10)
           (mesg "cf" "in" '(init . ((init-value . "here")
                                    (choices . ("out" "res" "get-text")))))
           (mesg "cf" "in" '(append . "A new value"))
           ; radio-box
           (node "rb" "gui/radio-box")
           (edge "rb" "out" #f "vp" "place" 11)
           (mesg "rb" "in" '(init .((label . "Please choice : ")
                                   (choices . ("42" "666")))))
           ; List-box
           (node "lb" "gui/list-box")
           (edge "lb" "out" #f "vp" "place" 12)
           (mesg "lb" "in" '(init . ((label . "a test: ")
                                    (choices . ("42" "666" "1" "7"))
                                    (columns . ("Number")))))
           ; Choice
           (node "choice" "gui/choice")
           (edge "choice" "out" #f "vp" "place" 13)
           (mesg "choice" "in" '(init . ((label . "choice test: ")
                                        (choices . ("1" "7" "42" "666")))))
           ; HP
           (node "hp" "gui/horizontal-panel")
           (edge "hp" "out" #f "vp" "place" 3)
           ; dynamic
           (node "but-add" "gui/button")
           (edge "but-add" "out" #f "hp" "place" 10)
           (mesg "but-add" "in" '(init . ((label . "&add counter"))))
           (node "but-rem" "gui/button")
           (edge "but-rem" "out" #f "hp" "place" 20)
           (mesg "but-rem" "in" '(init . ((label . "&remove counter"))))
           (node "dynamic" "test/dynamic")
           (edge "dynamic" "out" #f "vp" "place" 99)
           (mesg "dynamic" "option" "test/counter")
           (edge "but-add" "out" 'button "dynamic" "in" #f)
           (node "to-remove" "test/to-remove")
           (edge "but-rem" "out" 'button "to-remove" "in" #f)
           (edge "to-remove" "out" #f "dynamic" "in" #f)
           ))
