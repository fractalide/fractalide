#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out")
  (fun
   (for ([msg ((recv (input "option")) (recv (input "in")))])
     (send (output "out") msg))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Identity function"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg "hello")

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "option" list))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) msg)

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) msg)

   (sched (msg-stop)))

  (test-case
   "Reverse function"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg '(1 2 3))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "option" (compose list reverse)))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) (reverse msg))

   (sched (msg-mesg "agent-under-test" "in" (reverse msg)))
   (check-equal? (port-recv tap) msg)

   (sched (msg-stop)))

  (test-case
   "No messages"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg '(1 2 3))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "option" (lambda (_) (list))))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-false (port-try-recv tap))

   (sched (msg-stop)))

  (test-case
   "Two messages"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msg '(1 2))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "option" identity))

   (sched (msg-mesg "agent-under-test" "in" msg))
   (check-equal? (port-recv tap) (first msg))
   (check-equal? (port-recv tap) (second msg))

   (sched (msg-stop))))
