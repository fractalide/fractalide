#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         racket/match
         racket/list
         (prefix-in gui: racket/gui)
         (prefix-in class: racket/class))

(define (generate input)
  (lambda (frame)
    (let* ([widget
            (parameterize ([gui:current-eventspace (class:send frame get-eventspace)])
              (class:new gui:menu-bar% [parent frame]))])
        (send (input "acc") widget))))

(define-agent
  #:input '("in")
  #:input-array '("place")
  #:output '("out")
  #:output-array '("out")
   (define acc (try-recv (input "acc")))
   (set! acc (or acc
                 (begin
                   (send (output "out") (cons 'init (generate input)))
                   (cons '() (recv (input "acc"))))))

   ; Check for the simple input port
   (define msg-in (try-recv (input "in")))
   (match msg-in
     ; no msg
     [#f (void)]
     ; check for a message
     [else (send-action output output-array msg-in)])

   ; Check for place
   (for ([(place sub) (input-array "place")])
     (define msg (try-recv sub))
     (match msg
       ; no msg
       [#f (void)]
       ; there is msg
       [(cons 'init cont)
        ; add it
        (cont (cdr acc))
        ; save it
        (define menu (last (class:send (cdr acc) get-items)))
        (set! acc (cons (add-ordered (car acc) place menu)
                        (cdr acc)))
        ; clean the menu bar
        (for ([item (class:send (cdr acc) get-items)])
          (class:send item delete))
        ; Recreate all the menu
        (for ([item (car acc)])
          (parameterize ([gui:current-eventspace (class:send (class:send (cdr acc) get-frame) get-eventspace)])
            (class:send (cdr item) restore)))
        ]
       [else (send-action output output-array msg)]
       )
     )
   (send (output "acc") acc))

(define (add-ordered acc key val)
  (define (add-ordered ls acc)
    (cond
      [(empty? ls) (reverse (cons (cons key val) acc))]
      [(= (caar ls) key)
       (append (reverse (cons (cons key val) acc)) (cdr ls))]
      [(> (caar ls) key)
       (append (reverse (cons (cons key val) acc)) ls)]
      [else
       (add-ordered (cdr ls) (cons (car ls) acc))]))
  (add-ordered acc '()))
