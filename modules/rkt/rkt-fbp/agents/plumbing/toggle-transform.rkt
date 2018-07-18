#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out")
  (fun
   (define option (recv (input "option")))
   (send (input "option") (cons (cdr option) (car option)))
   (send (output "out") ((car option) (recv (input "in"))))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Identity function and reverse function toggle"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg '(1 2 3))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "option" (cons identity reverse)))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) msg)

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) (reverse msg))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) msg)

   (sched (msg-stop))))
