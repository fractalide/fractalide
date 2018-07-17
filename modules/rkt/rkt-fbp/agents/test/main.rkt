#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; VP
  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; dummy text field
  (node "tf" ${gui.text-field})
  (edge "tf" "out" _ "vp" "place" 1)
  (mesg "tf" "in" '(init . ((label . "test: "))))
  ; dummy check box
  (node "cb" ${gui.check-box})
  (edge "cb" "out" _ "vp" "place" 7)
  (mesg "cb" "in" (cons 'set-value #t))
  (mesg "cb" "in" (cons 'init '((label . "This is a check-box"))))
  ; Slider
  (node "slider" ${gui.slider})
  (edge "slider" "out" _ "vp" "place" 8)
  (mesg "slider" "in" '(init . ((label . "a slider : ")
                                (min-value . 0)
                                (max-value . 100))))
  ; Gauge
  (node "gauge" ${gui.gauge})
  (edge "gauge" "out" _ "vp" "place" 9)
  (mesg "gauge" "in" '(init . ((range . 50))))
  (mesg "gauge" "in" '(set-value . 20))
  ; combo-field
  (node "cf" ${gui.combo-field})
  (edge "cf" "out" _ "vp" "place" 10)
  (mesg "cf" "in" '(init . ((init-value . "here")
                            (choices . ("out" "res" "get-text")))))
  (mesg "cf" "in" '(append . "A new value"))
  ; radio-box
  (node "rb" ${gui.radio-box})
  (edge "rb" "out" _ "vp" "place" 11)
  (mesg "rb" "in" '(init .((label . "Please choice : ")
                           (choices . ("42" "666")))))
  ; List-box
  (node "lb" ${gui.list-box})
  (edge "lb" "out" _ "vp" "place" 12)
  (mesg "lb" "in" '(init . ((label . "a test: ")
                            (choices . ("42" "666" "1" "7"))
                            (columns . ("Number")))))
  ; HP
  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 3)
  ; dynamic
  (node "but-add" ${gui.button})
  (edge "but-add" "out" _ "hp" "place" 10)
  (mesg "but-add" "in" '(init . ((label . "&add counter"))))
  (node "but-rem" ${gui.button})
  (edge "but-rem" "out" _ "hp" "place" 20)
  (mesg "but-rem" "in" '(init . ((label . "&remove counter"))))
  (node "dynamic" ${test.dynamic})
  (edge "dynamic" "out" _ "vp" "place" 99)
  (mesg "dynamic" "option" "${test.counter}")
  (edge "but-add" "out" 'button "dynamic" "in" _)
  (node "to-remove" "${test.to-remove}")
  (edge "but-rem" "out" 'button "to-remove" "in" _)
  (edge "to-remove" "out" _ "dynamic" "in" _)
  ; Choice
  (node "choice" ${gui.choice})
  (edge "choice" "out" _ "vp" "place" 109)
  (mesg "choice" "in" '(init . ((label . "Select your counter : ")
                                (choices . ("1" "2" "3")))))
  ; Place-holder
  (node "ph" ${gui.place-holder})
  (edge "ph" "out" _ "vp" "place" 110)
  (node "counter1" ${test.counter})
  (node "counter2" ${test.counter})
  (node "counter3" ${test.counter})
  (edge "counter1" "out" _ "ph" "place" 1)
  (edge "counter2" "out" _ "ph" "place" 2)
  (edge "counter3" "out" _ "ph" "place" 3)
  (mesg "counter1" "in" '(display . #t))
  ; connection between choice and place-holder
  (node "to-display" ${test.to-display})
  (edge "choice" "out" 'choice "to-display" "in" _)
  (edge "to-display" "out" "1" "counter1" "in" _)
  (edge "to-display" "out" "2" "counter2" "in" _)
  (edge "to-display" "out" "3" "counter3" "in" _)
  ; Quit button
  (node "but-quit" "${gui.button}")
  (node "ip-to-close" "${test.to-close}")
  (edge "but-quit" "out" 'button "ip-to-close" "in" _)
  (edge "but-quit" "out" _ "vp" "place" 2)
  (edge "ip-to-close" "out" _ "frame" "in" _)
  (mesg "but-quit" "in" '(init . ((label . "&Close"))))
  )

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
