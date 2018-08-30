#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in" "password")
  #:output '("out")
   (define maybe-passwd (try-recv (input "password")))
   (define maybe-acc (try-recv (input "acc")))
   (define password (or maybe-passwd maybe-acc))
   (define button-pushed? (try-recv (input "in")))
   (when (and button-pushed? (and password (> (string-length password) 0)))
         (send (output "out") password))
   (send (output "acc") password))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Password sent when button pushed, password set"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (define password "hello")

   (sched (msg-mesg "agent-under-test" "password" password)
          (msg-mesg "agent-under-test" "in" #t))
   (check-equal? (port-recv tap) password)
   (sched (msg-stop)))

  (test-case
   "Password not sent when button pushed, password not set"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "in" #t))
   (check-false (port-try-recv tap))
   (sched (msg-stop)))

  (test-case
   "Password not sent when password set, button not pushed"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (define password "hello")

   (sched (msg-mesg "agent-under-test" "password" password))
   (check-false (port-try-recv tap))
   (sched (msg-stop)))

  (test-case
   "Password not sent when button pushed, password set then reset"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (sched (msg-mesg "agent-under-test" "password" "hello")
          (msg-mesg "agent-under-test" "password" "")
          (msg-mesg "agent-under-test" "in" #t))
   (check-false (port-try-recv tap))
   (sched (msg-stop))))
