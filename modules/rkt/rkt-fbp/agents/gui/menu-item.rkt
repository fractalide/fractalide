#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (prefix-in class: racket/class))

(define base-default
  (hash 'label #f
        'shortcut #f
        'help-string #f
        'shortcut-prefix (get-default-shortcut-prefix)
        ))

(define (generate input data)
  (lambda (frame)
    (define default (for/fold ([acc base-default])
                              ([d data])
                              (hash-set acc (car d) (cdr d))))
    (let* ([cb (class:new menu-item% [parent frame]
                          [label (hash-ref default 'label)]
                          [shortcut (hash-ref default 'shortcut)]
                          [shortcut-prefix (hash-ref default 'shortcut-prefix)]
                          [help-string (hash-ref default 'help-string)]
                          [callback (lambda (item event)
                                      (define msg (or (try-recv (input "option"))
                                                      (cons 'button #t)))
                                      (send (input "in") msg)
                                      )]
                          )])
      (send (input "acc") cb))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  ; (set! managed (window-manage widget msg output output-array))
  (if managed
      (void)
      (match msg
        [else (send-action output output-array msg)])))

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
    (define acc (try-recv (input "acc")))
    (define msg (recv (input "in")))
    (set! acc (manage acc msg input output output-array generate process-msg))
    (send (output "acc") acc)))
