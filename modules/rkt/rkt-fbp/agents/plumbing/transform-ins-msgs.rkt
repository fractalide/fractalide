#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input-array '("in")
  #:output '("out")
   (define latest-acc (or (try-recv (input "acc")) (make-hash)))
   (define acc (for/hash ([(k port) (in-hash (input-array "in"))]) (values k (or (try-recv port) (hash-ref latest-acc k #f)))))
   (when (for/and ([v (in-hash-values acc)]) v)
         (define msgs ((recv (input "option")) acc))
         (for ([msg msgs]) (send (output "out") msg)))
   (send (output "acc") acc))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Collect inputs into set"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msgs '(1 2 3 4 5))
   (define ports '("a" "b" "c" "d" "e"))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (for ([port ports])
        (sched (msg-add-agent port 'plumbing/identity)
               (msg-connect-to-array port "out" "agent-under-test" "in" port)))

   (sched (msg-mesg "agent-under-test" "option"
                    (lambda (ins) (list (for/set ([v (in-hash-values ins)]) v)))))

   (for ([msg msgs] [port ports])
        (sched (msg-mesg port "in" msg)))

   (check-equal? (port-recv tap) (list->set msgs)))

  (test-case
   "No output until all inputs received"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define ports '("a" "b" "c" "d" "e"))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (for ([port ports])
        (sched (msg-add-agent port 'plumbing/identity)
               (msg-connect-to-array port "out" "agent-under-test" "in" port)))

   (sched (msg-mesg "agent-under-test" "option" (lambda (ins) (list #t))))

   (sched (msg-mesg (car ports) "in" #t))

   (check-equal? (port-try-recv tap) #f))

  (test-case
   "Send multiple messages"
   (define sched (make-scheduler #f))
   (define tap (make-port 30 #f #f #f))

   (define msgs '(1 2 3 4 5))
   (define ports '("a" "b" "c" "d" "e"))

   (sched (msg-add-agent "agent-under-test" (quote-module-path ".."))
          (msg-raw-connect "agent-under-test" "out" tap))

   (for ([port ports])
        (sched (msg-add-agent port 'plumbing/identity)
               (msg-connect-to-array port "out" "agent-under-test" "in" port)))

   (sched (msg-mesg "agent-under-test" "option"
                    (lambda (ins) (hash-values ins))))

   (for ([msg msgs] [port ports])
        (sched (msg-mesg port "in" msg)))

   (define received-set (for/fold ([acc (set)]) ([dummy-msg msgs]) (set-add acc (recv tap))))
   (check-equal? received-set (list->set msgs))))
