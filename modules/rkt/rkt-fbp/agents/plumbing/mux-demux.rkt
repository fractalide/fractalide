#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input-array '("in")
  #:output-array '("out")
   (define f (or (try-recv (input "option")) list))
   (for ([(selection port) (input-array "in")])
        (define in-msg (try-recv port))
        (when in-msg
              (for ([sel-msg (f (cons selection in-msg))])
                   (match-define (cons sel msg) sel-msg)
                   (send (hash-ref (output-array "out") sel) msg)))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Sending message Y to port X yields message Y on port X"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define selection "the-selection")
   (define msg "hello")

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))

          (msg-add-agent "in" 'plumbing/identity)
          (msg-add-agent "out" 'plumbing/identity)
          (msg-connect-to-array "in" "out" "agent-under-test" "in" selection)
          (msg-connect-array-to "agent-under-test" "out" selection "out" "in")
          (msg-raw-connect "out" "out" tap))

   (sched (msg-mesg "in" "in" msg))
   (check-equal? (port-recv tap) msg)
   (sched (msg-stop)))

  (test-case
   "Transform msg"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define selection "the-selection")
   (define msg '(1 2 3 4))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))

          (msg-add-agent "in" 'plumbing/identity)
          (msg-add-agent "out" 'plumbing/identity)
          (msg-connect-to-array "in" "out" "agent-under-test" "in" selection)
          (msg-connect-array-to "agent-under-test" "out" selection "out" "in")
          (msg-raw-connect "out" "out" tap))

   (sched (msg-mesg "agent-under-test" "option"
                    (match-lambda [(cons sel msg)
                                   (list (cons sel (reverse msg)))]))
          (msg-mesg "in" "in" msg))
   (check-equal? (port-recv tap) (reverse msg))
   (sched (msg-stop)))

  (test-case
   "Reroute"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define in-selection "the-selection")
   (define out-selection "other-selection")
   (define msg '(1 2 3 4))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))

          (msg-add-agent "in" 'plumbing/identity)
          (msg-add-agent "out" 'plumbing/identity)
          (msg-connect-to-array "in" "out" "agent-under-test" "in" in-selection)
          (msg-connect-array-to "agent-under-test" "out" out-selection "out" "in")
          (msg-raw-connect "out" "out" tap))

   (sched (msg-mesg "agent-under-test" "option"
                    (match-lambda [(cons (== in-selection) msg)
                                   (list (cons out-selection msg))]))
          (msg-mesg "in" "in" msg))
   (check-equal? (port-recv tap) msg)))
