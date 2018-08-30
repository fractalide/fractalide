#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input-array '("in")
  #:output '("out")
   (define f (or (try-recv (input "option")) list))
   (for ([(selection port) (input-array "in")])
        (define in-msg (try-recv port))
        (when in-msg
              (for ([msg (f (cons selection in-msg))])
                   (send (output "out") msg)))))

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
   (sched (msg-stop)))

  (test-case
   "Transform"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define selection "the-selection")
   (define msg '(1 2 3 4))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap)

          (msg-add-agent "identity" 'plumbing/identity)
          (msg-connect-to-array "identity" "out" "agent-under-test" "in" selection))

   (sched (msg-mesg "agent-under-test" "option"
                    (match-lambda [(cons sel msg)
                                   (list (cons sel (reverse msg)))]))
          (msg-mesg "identity" "in" msg))
   (check-equal? (port-recv tap)
                 (cons selection (reverse msg)))
   (sched (msg-stop))))
