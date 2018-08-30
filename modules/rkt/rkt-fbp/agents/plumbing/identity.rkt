#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out")
   (send (output "out") (recv (input "in"))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Sending message X returns message X"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg "hello")

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) msg)
   (sched (msg-stop))))

