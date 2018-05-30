#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.node})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (fun
    (define msg (recv (input "in")))
    (define exec
      (let ([out (open-output-string)])
        (parameterize ([current-output-port out]
                       [current-error-port out])
          (system (string-append "racket " msg)))
        (get-output-string out)))
    (send (output "out") exec)))
