#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.node})

(define agt
  (define-agent
    #:input '("in") ; in array port
    #:output '("out") ; out port
    #:proc
    (lambda (input output input-array output-array)
      (define msg (recv (input "in")))
      (define exec
        (let ([out (open-output-string)])
          (parameterize ([current-output-port out]
                         [current-error-port out])
            (system (string-append "racket " msg)))
          (get-output-string out)))
      (send (output "out") exec))))
