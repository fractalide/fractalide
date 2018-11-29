#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})
(require/edge ${fvm.dynamic-add})

(define-agent
  #:input '("in") ; in array port
  #:output '("out" "build") ; out port
  (define msg (recv (input "in")))
  (define acc (try-recv (input "acc")))
  (unless acc (set! acc (cons #f (list))))
  (match msg
    [(cons 'init w) #:when (wallet? w)
                    (send (output "build") w)
                    ; clean graph
                    (define g (make-graph))
                    (when (not (empty? (cdr acc)))
                      (send (output "out") '(delete . #t))
                      (for ([n (cdr acc)])
                        (set! g (make-graph
                                 g
                                 (node n ${dummy}))))
                      (dynamic-remove g input output))
                    (set! acc (cons (car acc) (list)))
                    ; build new one
                    (define toggle (if (car acc) "show" "hide"))
                    (set! g (make-graph
                               (node "vp" ${gui.vertical-panel})
                               (edge-out "vp" "out" "dynamic-out")
                               (node "details-btn" ${gui.button})
                               (edge "details-btn" "out" _ "vp" "place" 0)
                               (mesg "details-btn" "in" '(init . ((label . "Used addresses"))))
                               (mesg "details-btn" "option" (cons 'toggle #t))

                               (node "maybe" ${gui.place-holder})
                               (edge "maybe" "out" _ "vp" "place" 1)
                               (node "hide" ${gui.vertical-panel})
                               (edge "hide" "out" _ "maybe" "place" 0)
                               (node "show" ${gui.vertical-panel})
                               (edge "show" "out" _ "maybe" "place" 1)
                               (mesg toggle "in" (cons 'display #t))))
                    (set! acc (cons (car acc) (list "vp" "details-btn" "maybe" "hide" "show")))
                    (for ([i (in-naturals 1)]
                          [a (wallet-addresses w)])
                      (define name (number->string i))
                      (set! acc (cons (car acc) (cons name (cdr acc))))
                      (set! g (make-graph
                               g
                               (node name ${gui.message})
                               (edge name "out" _ "show" "place" i)
                               (mesg name "in" (cons 'init (list (cons 'label a)))))))
                    (send-dynamic-add g input output)]

    [(cons 'toggle #t)
     (set! acc (cons (not (car acc)) (cdr acc)))
     (if (car acc)
         (send-dynamic-add (make-graph (mesg "show" "in" '(display . #t))) input output)
         (send-dynamic-add (make-graph (mesg "hide" "in" '(display . #t))) input output))]
    [else (send (output "out") msg)])
  (send (output "acc") acc))
