#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out" "delete")
  (fun
    (let* ([msg (recv (input "in"))]
           [acc (recv (input "acc"))]
           [option (try-recv (input "option"))]
           [step (or option 1)]
           [sum (+ step acc)])
      (if (= sum 3)
          (send (output "delete") (cons 'delete #t))
          (void))
      (send (output "out") (cons 'set-label (string-append "button clicked : " (number->string sum))))
      (send (output "acc") sum))))
