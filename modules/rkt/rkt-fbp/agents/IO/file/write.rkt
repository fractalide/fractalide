#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         racket/file)

(require/edge ${io.file.write})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (fun
    (define data (recv (input "in")))
    (define option (recv (input "option")))
    (display-to-file data
                   (write-path option)
                   #:exists (write-exists option)
                   #:mode (write-mode option))
    (send (output "out") (file->string (write-path option)))))
