#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match
         racket/list
         racket/string)
(require (rename-in racket/class [send class-send]))

(struct choices (full-name index name widget))

(define (generate input)
  (lambda (frame)
    (let* ([ph (new tab-panel%
                    [parent frame]
                    [choices '()]
                    [callback (lambda (widget event)
                                (send (input "in")
                                      (cons 'set
                                            (class-send widget get-selection))))])])
      (send (input "acc") ph))))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place")
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
    (define acc (try-recv (input "acc")))
    (define msg-in (try-recv (input "in")))
    ; Init the first time
    (define ph (if acc
                   acc
                   (begin
                     (send (output "out") (cons 'init (generate input)))
                     (cons '() (recv (input "acc"))))))
    (if msg-in
        ; TRUE : A message in the input port
        (match msg-in
               [(cons 'set index)
                (class-send (cdr ph) change-children
                            (lambda (_)
                              (list (choices-widget (list-ref (car ph) index)))))]
               [else (send-action output output-array msg-in)])
        ; FALSE : At least a message in the input array port
        ; Change the accumulator ph with set!
        (for ([(place containee) (input-array "place")])
             (define msg (try-recv containee))
             (if msg
                 (match msg
                        [(cons 'init cont)
                         (class-send (cdr ph) begin-container-sequence)
                         ; Add it
                         (cont (cdr ph))
                         ; Get back the children, but no display
                         (class-send (cdr ph) change-children
                                     (lambda (act)
                                       ; get the new one
                                       (define val (last act))
                                       ; add it in the acc
                                       (set! ph (cons (insert-ordered (car ph) place val)
                                                      (cdr ph)))
                                       (if (> (length act) 1)
                                           (list (car act))
                                           '())))
                         (class-send (cdr ph) end-container-sequence)
                         (update-choices (car ph) (cdr ph))]
                        ; Drop the children, but no change in display
                        [(cons 'delete #t)
                         (set! ph (cons (remove (car ph) place)
                                        (cdr ph)))
                         (update-choices (car ph) (cdr ph))]
                        ; Display a new children
                        [(cons 'display #t)
                         (class-send (cdr ph) change-children
                                     (lambda (_)
                                       (list (choices-widget (findf (lambda (elem)
                                                                      (string=? (choices-full-name elem) place))
                                                                    (car ph))))))]
                        [else (send-action output output-array msg)])
                 void)))

    (send (output "acc") ph))))

(define (split-place place)
  (define ls (string-split place ";"))
  (define num (string->number (car ls)))
  (define lr (string-join (cdr ls) ";"))
  (values num lr))

(define (insert-ordered ls place widget)
  (define-values (index name) (split-place place))
  (define nls (cons (choices place index name widget) ls))
  (sort nls (lambda (x y)
              (< (choices-index x) (choices-index y)))))

(define (update-choices acc widget)
  (define choices (map (lambda (elem) (choices-name elem))
                       acc))
  (class-send widget set choices)
