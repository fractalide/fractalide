#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require (prefix-in gui: racket/gui))

(require/edge ${cantor.wallet})

(define-agent
  #:input '("in" "receive") ; in port
  #:output '("out" "receive") ; out port
  #:output-array '("out")
  (define msg (recv (input "in")))

  (match msg
    [(cons 'change-view wlt)
     (send-action output output-array (cons 'wallet wlt))]
    [(cons 'wallet wallet)
     (send (output "out") (cons 'init (transform wallet input output)))]
    [else (send-action output output-array msg)]))

(define (transform wallet input output)
  (lambda(frame)
    (define hp (gui:new gui:horizontal-panel% [parent frame]))
    (buttons wallet hp input)
    (match (wallet-view wallet)
      ['summary (gui:new gui:message% [parent hp][label "Summary"])]
      ['send (gui:new gui:message% [parent hp][label "Send"])]
      ['receive
       (send (output "receive") `(wallet . ,wallet))
       (define init (cdr (recv (input "receive"))))
       (init hp)
       ]
      )))

(define (buttons wlt frame input)
  (define vp (gui:new gui:vertical-panel% [parent frame] [stretchable-width false]))
  (button wlt vp input "&Summary" 'summary)
  (button wlt vp input "&Send" 'send)
  (button wlt vp input "&Receive" 'receive)
  )

(define (button wlt frame input label view)
  (gui:new gui:button% [parent frame] [stretchable-width true]
           [label label]
           [callback (lambda (button event)
                       (send (input "in") (cons 'change-view (struct-copy wallet wlt [view view]))))])

  )
