#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define (list-remove-index lst idx)
  (define-values (heads tail) (split-at lst idx))
  (append heads (cdr tail)))

(define (list-replace-index lst idx elem)
  (build-list (length lst) (lambda (n)
   (if (= n idx) elem (list-ref lst n)))))

(define in-ports '("in" "add" "edit" "select" "delete"))
(define out-ports '("out" "choices" "select"))

(define-agent
  #:input in-ports
  #:output out-ports
  (fun
   (define acc (or (try-recv (input "acc")) #hash((selection . 0) (state . ()))))
   (match-define (hash-table ('selection selection) ('state state)) acc)
   (define action (for/or ([port in-ports])
                          (define val (try-recv (input port)))
                          (if val (cons port val) #f)))
   (for ([port-msg (match action
                    [(cons "in" (list))
                     (list (cons "acc" #hash((selection . 0) (state . ())))
                           (cons "choices" (list))
                           (cons "select" 0)
                           (cons "out" (make-hash)))]
                    [(cons "in" (list-rest head rest))
                     (define new-state (list* head rest))
                     (list (cons "acc" (hash-set acc 'state new-state))
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-state))
                           (cons "select" 0)
                           (cons "out" head))]
                    [(cons "add" wallet-data)
                     (define new-state (append state (list wallet-data)))
                     (define new-selection (sub1 (length new-state)))
                     (list (cons "acc" `#hash((state . ,new-state)
                                              (selection . ,new-selection)))
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-state))
                           (cons "select" new-selection)
                           (cons "out" wallet-data))]
                    [(cons "edit" new-wallet-data)
                     (define new-state (list-replace-index state selection new-wallet-data))
                     (list (cons "acc" (hash-set acc 'state new-state))
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-state))
                           (cons "out" new-wallet-data))]
                    [(cons "delete" delete-selection)
                     (define new-selection (min (max 0 (- (length state) 2))
                                                selection))
                     (define new-state (list-remove-index state delete-selection))
                     (list (cons "acc" `#hash((state . ,new-state)
                                              (selection . ,new-selection)))
                           (cons "choices" (map (lambda (h) (hash-ref h 'name)) new-state))
                           (cons "select" new-selection)
                           (cons "out" (list-ref new-state new-selection)))]
                    [(cons "select" new-selection)
                     (list (cons "acc" (hash-set acc 'selection new-selection))
                           (cons "out" (list-ref state new-selection)))])])
        (match-define (cons port msg) port-msg)
        (send (output port) msg))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (define (run-sched-test test)
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port out-ports]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (test sched taps)
   (sched (msg-stop)))

  (test-case
   "In"
   (run-sched-test (lambda (sched taps)
    (define choices '("asdf" "qwer"))
    (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

    (sched (msg-mesg "agent-under-test" "in" wallets))
    (check-equal? (port-recv (hash-ref taps "select")) 0)
    (check-equal? (port-recv (hash-ref taps "out")) (car wallets))
    (check-equal? (port-recv (hash-ref taps "choices")) choices))))

  (test-case
   "Select"
   (run-sched-test (lambda (sched taps)
    (define wallets (list #hash((name . "asdf"))
                          #hash((name . "qwer"))))

    (sched (msg-mesg "agent-under-test" "in" wallets))
    (port-recv (hash-ref taps "select"))
    (port-recv (hash-ref taps "out"))
    (port-recv (hash-ref taps "choices"))

    (sched (msg-mesg "agent-under-test" "select" 1))
    (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
    (check-equal? (port-try-recv (hash-ref taps "choices")) #f))))

  (test-case
   "Add"
   (run-sched-test (lambda (sched taps)
    (define choices '("asdf" "qwer"))
    (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

    (sched (msg-mesg "agent-under-test" "add" (first wallets)))
    (check-equal? (port-recv (hash-ref taps "select")) 0)
    (check-equal? (port-recv (hash-ref taps "out")) (first wallets))
    (check-equal? (port-recv (hash-ref taps "choices")) (list (first choices)))

    (sched (msg-mesg "agent-under-test" "add" (second wallets)))
    (check-equal? (port-recv (hash-ref taps "select")) 1)
    (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
    (check-equal? (port-recv (hash-ref taps "choices")) choices))))

  (test-case
   "Edit"
   (run-sched-test (lambda (sched taps)
    (define choices '("asdf" "qwer"))
    (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))
    (define new-state #hash((name . "zxcv")))
    (define new-wallets (list new-state (second wallets)))
    (define new-choices (list (hash-ref new-state 'name) (second choices)))

    (sched (msg-mesg "agent-under-test" "in" wallets))
    (port-recv (hash-ref taps "select"))
    (port-recv (hash-ref taps "out"))
    (port-recv (hash-ref taps "choices"))

    (sched (msg-mesg "agent-under-test" "edit" new-state))
    (check-equal? (port-recv (hash-ref taps "out")) new-state)
    (check-equal? (port-recv (hash-ref taps "choices")) new-choices)

    (sched (msg-mesg "agent-under-test" "select" 1))
    (port-recv (hash-ref taps "out"))

    (sched (msg-mesg "agent-under-test" "select" 0))
    (check-equal? (port-recv (hash-ref taps "out")) new-state))))

  (test-case
   "Delete"
   (run-sched-test (lambda (sched taps)
    (define choices '("asdf" "qwer"))
    (define wallets (map (lambda (choice) (make-hash (list (cons 'name choice)))) choices))

    (sched (msg-mesg "agent-under-test" "in" wallets))
    (port-recv (hash-ref taps "select"))
    (port-recv (hash-ref taps "out"))
    (port-recv (hash-ref taps "choices"))

    (sched (msg-mesg "agent-under-test" "delete" 0))
    (check-equal? (port-recv (hash-ref taps "select")) 0)
    (check-equal? (port-recv (hash-ref taps "out")) (second wallets))
    (check-equal? (port-recv (hash-ref taps "choices")) (list (second choices)))))))
