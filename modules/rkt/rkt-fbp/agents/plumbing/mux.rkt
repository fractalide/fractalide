#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input-array '("in")
  #:output '("out")
  (fun
   (for ([(selection port) (input-array "in")])
        (define msg (try-recv port))
        (when msg (send (output "out") (cons selection msg))))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Sending message Y to port X yields message (X . Y)"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define selection "the-selection")
   (define msg "hello")

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap)

          (msg-add-agent "identity" 'plumbing/identity)
          (msg-connect-to-array "identity" "out" "agent-under-test" "in" selection))

   (sched (msg-mesg "identity" "in" msg))
   (check-equal? (port-recv tap)
                 (cons selection msg))
   (sched (msg-stop))))

