#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define (list-remove-index lst idx)
  (define-values (heads tail) (split-at lst idx))
  (append heads (cdr tail)))

(define-agent
  #:input '("in" "add" "select" "delete")
  #:output '("out")
  (fun
   (define acc (or (try-recv (input "acc")) (make-hash)))
   (define action (for/or ([port '("in" "add" "delete")])
                          (define val (try-recv (input port)))
                          (if val (cons port val) #f)))
   (for ([port-msg (match action
                    [(cons "in" (list))
                     (list (cons "acc" (list))
                           (cons "selection" 0)
                           (cons "out" (make-hash)))]
                    [(cons "in" (list-rest head rest))
                     (list (cons "acc" (list* head rest))
                           (cons "selection" 0)
                           (cons "out" head))]
                    [(cons "add" wallet-data)
                     (list (cons "acc"
                                 (append acc (list wallet-data)))
                           (cons "selection" (length acc))
                           (cons "out" wallet-data))]
                    [(cons "delete" selection)
                     (define new-selection (min (max 0 (- (length acc) 2))
                                                selection))
                     (define new-acc (list-remove-index acc selection))
                     (list (cons "acc" new-acc)
                           (cons "selection" new-selection)
                           (cons "out" (list-ref new-acc new-selection)))])])
        (match-define (cons port msg) port-msg)
        (send (output port) msg))))

(module+ test
  (require rackunit)
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

  (test-case
   "Initializing gives us head wallet"
   (define sched (make-scheduler #f))
   (define taps (for/hash ([port '("selection" "out")]) (values port (make-port 30 #f #f #f))))

   (sched (msg-add-agent "agent-under-test" (quote-module-path "..")))

   (for ([(port tap) (in-hash taps)])
        (sched (msg-raw-connect "agent-under-test" port tap)))

   (define wallets (list #hash(("name" . "asdf"))
                         #hash(("name" . "qwer"))))

   (sched (msg-mesg "agent-under-test" "in" wallets))
   (check-equal? (port-recv (hash-ref taps "selection")) 0)
   (check-equal? (port-recv (hash-ref taps "out")) (car wallets))
   (sched (msg-stop))))
