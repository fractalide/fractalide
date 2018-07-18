#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define-agent
  #:input '("in") ; in port
  #:output '("out" "halt" "fvm") ; out port
  (fun
   (define acc (try-recv (input "acc")))
   (define msg (recv (input "in")))
   (define fr (if acc
                  acc
                  (let* ([new-es (make-eventspace)]
                         [fr
                          (parameterize ([current-eventspace new-es])
                            (new frame% [label "Example"]))])
                    (class-send fr show #t)
                    fr)))
   (match msg
     [(cons 'init curry) (curry fr)]
     [(cons 'dynamic-add _)
      (send (output "fvm") msg)]
     [(cons 'dynamic-remove graph)
      (send (output "fvm") msg)]
     [(cons 'close #t) (send (output "halt") #t) (send (output "fvm") (cons 'stop #t))]
     [(cons (or 'motion 'leave 'enter 'left-down 'left-up 'subwindow-focus
                'move 'superwindow-show 'size 'focus 'radio-box 'key 'list-box
                'text-field 'check-box 'slider)
            _) (void)]
     [else (display "msg: ") (displayln msg)])
   (send (output "acc") fr)))
