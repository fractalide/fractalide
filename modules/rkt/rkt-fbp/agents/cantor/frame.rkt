#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(require (rename-in racket/gui [send class-send]))

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  (define acc (try-recv (input "acc")))
  (define msg (recv (input "in")))
  (unless acc (set! acc
                    (let* ([new-es (make-eventspace)]
                           [fr (parameterize ([current-eventspace new-es])
                                 (new frame% [label "Cantor"]))])
                      (class-send fr show #t)
                      fr)))

   (match msg
     [(cons 'init curry)
      (class-send acc begin-container-sequence)
      (class-send acc change-children (lambda(ls) '()))
      (curry acc)
      (class-send acc end-container-sequence)]
     [else (display "msg: ") (displayln msg)])
   (send (output "acc") acc))
