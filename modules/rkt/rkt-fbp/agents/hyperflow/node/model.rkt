#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.node})
(require/edge ${io.file.write})

(define-agent
  #:input '("in") ; in array port
  #:input-array '("compute")
  #:output '("out" "code" "eval" "save") ; out port
  #:output-array '("compute")
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
           [(cons 'init type)
            (set! acc (node type))
            (send (output "code") (cons 'init (list (cons 'init-value "not yet loaded")
                                                    (cons 'style (list 'multiple)))))
            (send (output "eval") '(init . ((init-value . "Not yet evaluated")
                                            (style . (multiple)))))
            (send (input "in") (cons 'update-type (node-type acc)))]
           [(cons 'update-type "")
            (send (output "eval") '(set-value . "Please enter a type for the node"))]
           [(cons 'update-type type)
            (set! acc (struct-copy node acc [type type]))
            ; Code
            (send (hash-ref (output-array "compute") 'update-code) (node-type acc))
            (define code (recv (hash-ref (input-array "compute") 'update-code)))
            (send (output "code")
                  (cons 'set-value code))
            (send (output "code")
                  '(refresh . #t))
            ; Option for save
            (send (output "save")
                  (make-write (node-type acc) 'binary 'replace))
            ; Update the eval
            (send (input "in")
                  (cons 'update-code #t))]
           [(cons 'update-code _)
            ; Eval
            (send (output "eval") '(set-value . "..."))
            (send (hash-ref (output-array "compute") 'exec) (node-type acc))
            (define res-exec (recv (hash-ref (input-array "compute") 'exec)))
            (send (output "eval")
                  (cons 'set-value res-exec))
            (send (output "eval")
                  '(refresh . #t))
            ]
           [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
