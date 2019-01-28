#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require (prefix-in gui: racket/gui))
(require racket/draw)
(require racket/runtime-path)

(define-runtime-path blank-path "./baconipsum.png")
; (define address-qr (read-bitmap address-qr-path))
(define-runtime-path qr-path "./qrcode.png")

(require/edge ${cantor.wallet})

(define-agent
  #:input '("in" "gen") ; in port
  #:output '("out" "gen") ; out port
  #:output-array '("out")
  (define msg (recv (input "in")))

  (match msg
    [(cons 'change-view wlt)
     (send-action output output-array (cons 'wallet wlt))]
    [(cons 'wallet wallet)
     (send (output "out") (cons 'init (transform wallet input output)))]
    [else (send-action output output-array msg)]))

(define (transform wlt input output)
  (lambda(frame)
    (define vp (gui:new gui:vertical-panel% [parent frame][stretchable-height #f]))
    (gui:new gui:message% [parent vp][label "Receive"])

    ; Generate a new addresses
    (define qr (if (equal? 'new (wallet-state-address wlt))
                   (read-bitmap qr-path)
                   (read-bitmap blank-path)))

    (define text (match (wallet-state-address wlt)
                   ['init "Fill password"]
                   ['wrong-pwd "Wrong password"]
                   ['new (car (wallet-addresses wlt))]))

    (gui:new gui:message% [parent vp][label "Generated addresses"])
    (define hp (gui:new gui:horizontal-panel% [parent vp]))
    (gui:new gui:message% [parent hp][label qr])
    (define right (gui:new gui:vertical-panel% [parent hp][stretchable-height #f]))
    (gui:new gui:message% [parent right][label text])
    (define down (gui:new gui:horizontal-panel% [parent right]))
    (define pwd (gui:new gui:text-field% [parent down][label "Password"][style '(single password)]))
    (gui:new gui:button% [parent down][label "Generate"]
             [callback (lambda (button event)
                         (gui:send button enable false)
                         (send (output "gen") (cons (gui:send pwd get-value) wlt)))])

    ; List of existing addresses
    (define lists #f)
    (define toggle #t)
    (gui:new gui:button% [parent vp][label "Hide"]
             [callback (lambda (button event)
                         (set! toggle (not toggle))
                         (gui:send lists show toggle)
                         (gui:send button set-label (if toggle "Hide" "Show")))])
    (set! lists (gui:new gui:vertical-panel% [parent vp]))

    (for ([add (wallet-addresses wlt)])
      (define hp (gui:new gui:horizontal-panel% [parent lists]))
      (gui:new gui:message% [parent hp][label add])
      (gui:new gui:button% [parent hp][label "copy"]
               [callback (lambda (button event)
                           (gui:send gui:the-clipboard set-clipboard-string add 0))]))
    ))

