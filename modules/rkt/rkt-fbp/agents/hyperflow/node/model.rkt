#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.node})

(define agt
  (define-agent
    #:input '("in") ; in array port
    #:input-array '("compute")
    #:output '("out" "code" "eval" "os-deps" "modules") ; out port
    #:output-array '("compute")
    #:proc
    (lambda (input output input-array output-array)
      (define msg (recv (input "in")))
      (define acc (try-recv (input "acc")))
      (match msg
        [(cons 'init type)
         (set! acc (node type (list) (list)))
         (send (output "code") (cons 'init (list (cons 'init-value "not yet loaded")
                                                 (cons 'style (list 'multiple)))))
         (send (output "eval") '(init . ((init-value . "Not yet evaluated")
                                         (style . (multiple)))))
         (send (input "in") (cons 'update-type (node-type acc)))]
        [(cons 'update-type "")
         (send (output "eval") '(set-value . "Please enter a type for the node"))]
        [(cons 'update-type type)
         (set! acc (struct-copy node acc [type type]))
         (send (hash-ref (output-array "compute") 'update-code) (node-type acc))
         (define code (recv (hash-ref (input-array "compute") 'update-code)))
         (send (output "code")
               (cons 'set-value code))
         (send (output "code")
               '(refresh . #t))
         (send (output "eval") '(set-value . "..."))
         (send (hash-ref (output-array "compute") 'exec) (node-type acc))
         (define res-exec (recv (hash-ref (input-array "compute") 'exec)))
         (send (output "eval")
               (cons 'set-value res-exec))
         (send (output "eval")
               '(refresh . #t))
         ]
        [(cons 'add-os-deps os-deps)
         (set! acc (struct-copy node acc [os-deps (cons os-deps (node-os-deps acc))]))
         (send (output "os-deps")
               (cons 'add
                     (cons 'init (list (cons 'label os-deps)
                                       (cons 'on-delete 'remove-os-deps)))))]
        [(cons 'remove-os-deps os-deps)
         (set! acc (struct-copy node acc [os-deps (remove os-deps (node-os-deps acc) string=?)]))]
        [(cons 'add-modules mod)
         (set! acc (struct-copy node acc [modules (cons mod (node-modules acc))]))
         (send (output "modules")
               (cons 'add
                     (cons 'init (list (cons 'label mod)
                                       (cons 'on-delete 'remove-modules)))))]
        [(cons 'remove-modules mod)
         (set! acc (struct-copy node acc [modules (remove mod (node-modules acc) string=?)]))]
        [else (send (output "out") msg)])
      (send (output "acc") acc)
      )))
