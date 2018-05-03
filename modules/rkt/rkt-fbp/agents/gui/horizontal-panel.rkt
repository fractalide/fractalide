#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)


(require racket/gui/base
         racket/match
         racket/list)
(require (rename-in racket/class [send class-send]))

(define (generate-hp input)
  (lambda (frame)
    (let* ([hp (new horizontal-panel% [parent frame]
                    [alignment '(center center)])])
      (send (input "acc") hp))))

(define agt (define-agent
              #:input '("in") ; in port
              #:input-array '("place")
              #:output '("out") ; out port
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array option)
                       (define acc (try-recv (input "acc")))
                       (define msg-in (try-recv (input "in")))
                       ; Init the first time
                       (define hp (if acc
                                      acc
                                      (begin
                                        (send (output "out") (vector "init" (generate-hp input)))
                                        (cons '() (recv (input "acc"))))))

                       (if msg-in
                           ; TRUE : A message in the input port
                           (match msg-in
                             [(vector "set-orientation" orientation)
                              (class-send (cdr hp) set-orientation orientation)]
                             [else (send-action output output-array msg-in)])
                           ; FALSE : At least a message in the input array port
                           ; Change the accumulator HP with set!
                           (for ([(place containee) (input-array "place")])
                             (define msg (try-recv containee))
                             (if msg
                                 (match msg
                                   [(vector "init" cont)
                                    ; Add it
                                    (cont (cdr hp))
                                    ; order
                                    (define index (index-of (sort (hash-keys (input-array "place")) <) place))
                                    (class-send (cdr hp) change-children
                                                (lambda (act)
                                                  (define val (last act))
                                                  (define ls (take act (- (length act) 1)))
                                                  (append-at-least ls index val '())
                                                  ))
                                    (set! hp (cons (sort (cons place (car hp)) <) (cdr hp)))
                                    ]
                                   [(vector "delete")
                                    (define index (index-of (car hp) place))
                                    (class-send (cdr hp) change-children
                                                (lambda (act)
                                                  (remove-at act index)))
                                    (set! hp (cons (remq index (car hp)) (cdr hp)))
                                    ]
                                   [else (send-action output output-array msg)])
                                 void)
                             ))

                       (send (output "acc") hp))))

(define (append-at-least ls k v acc)
  (cond
    [(empty? ls) (reverse (cons v acc))]
    [(= k 0) (append (reverse (cons v acc)) ls)]
    [else (append-at-least (cdr ls) (- k 1) v (cons (car ls) acc))]))

(define (remove-at ls k)
  (define (rem-acc ls k acc)
    (if (= k 0)
        (append (reverse acc) (cdr ls))
        (rem-acc (cdr ls) (- k 1) (cons (car ls) acc))))
  (rem-acc ls k '()))
