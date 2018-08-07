#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define (list-remove-index lst idx)
  (define-values (heads tail) (split-at lst idx))
  (append heads (cdr tail)))

(define ports '("in" "add" "select" "delete"))

(define-agent
  #:input ports
  #:output '("out" "choices" "select")
  (fun
   (define acc (or (try-recv (input "acc")) (list)))
   (define action (for/or ([port ports])
                          (define val (try-recv (input port)))
                          (if val (cons port val) #f)))
   (for ([port-msg (match action
                    [(cons "in" (list))
                     (list (cons "acc" (list))
                           (cons "choices" (list))
                           (cons "select" 0)
                           (cons "out" (make-hash)))]
                    [(cons "in" (list-rest head rest))
                     (define new-acc (list* head rest))
                     (list (cons "acc" new-acc)
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-acc))
                           (cons "select" 0)
                           (cons "out" head))]
                    [(cons "add" wallet-data)
                     (define new-acc (append acc (list wallet-data)))
                     (list (cons "acc" new-acc)
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-acc))
                           (cons "select" (length acc))
                           (cons "out" wallet-data))]
                    [(cons "delete" selection)
                     (define new-selection (min (max 0 (- (length acc) 2))
                                                selection))
                     (define new-acc (list-remove-index acc selection))
                     (list (cons "acc" new-acc)
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-acc))
                           (cons "select" new-selection)
                           (cons "out" (list-ref new-acc new-selection)))]
                    [(cons "select" selection)
                     (list (cons "acc" acc)
                           (cons "out" (list-ref acc selection)))])])
        (match-define (cons port msg) port-msg)
        (send (output port) msg))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "In"
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port '("choices" "select" "out")]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (define choices '("asdf" "qwer"))
   (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

   (sched (msg-mesg "agent-under-test" "in" wallets))
   (check-equal? (port-recv (hash-ref taps "select")) 0)
   (check-equal? (port-recv (hash-ref taps "out")) (car wallets))
   (check-equal? (port-recv (hash-ref taps "choices")) choices)
   (sched (msg-stop)))

  (test-case
   "Select"
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port '("choices" "select" "out")]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (define wallets (list #hash((name . "asdf"))
                         #hash((name . "qwer"))))

   (sched (msg-mesg "agent-under-test" "in" wallets))
   (port-recv (hash-ref taps "select"))
   (port-recv (hash-ref taps "out"))
   (port-recv (hash-ref taps "choices"))

   (sched (msg-mesg "agent-under-test" "select" 1))
   (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
   (check-equal? (port-try-recv (hash-ref taps "choices")) #f)
   (sched (msg-stop)))

  (test-case
   "Add"
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port '("choices" "select" "out")]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (define choices '("asdf" "qwer"))
   (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

   (sched (msg-mesg "agent-under-test" "add" (first wallets)))
   (check-equal? (port-recv (hash-ref taps "select")) 0)
   (check-equal? (port-recv (hash-ref taps "out")) (first wallets))
   (check-equal? (port-recv (hash-ref taps "choices")) (list (first choices)))

   (sched (msg-mesg "agent-under-test" "add" (second wallets)))
   (check-equal? (port-recv (hash-ref taps "select")) 1)
   (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
   (check-equal? (port-recv (hash-ref taps "choices")) choices)
   (sched (msg-stop)))

  (test-case
   "Delete"
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port '("choices" "select" "out")]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (define choices '("asdf" "qwer"))
   (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

   (sched (msg-mesg "agent-under-test" "in" wallets))
   (port-recv (hash-ref taps "select"))
   (port-recv (hash-ref taps "out"))
   (port-recv (hash-ref taps "choices"))

   (sched (msg-mesg "agent-under-test" "delete" 0))
   (check-equal? (port-recv (hash-ref taps "select")) 0)
   (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
   (check-equal? (port-recv (hash-ref taps "choices")) (list (second choices)))
   (sched (msg-stop))))
