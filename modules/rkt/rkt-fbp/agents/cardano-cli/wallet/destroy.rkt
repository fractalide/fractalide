#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)
(require racket/runtime-path)

(define-runtime-path destroy-exp "./destroy.exp")

(define-agent
  #:input '("name")
  #:output '("out")
  (define name (recv (input "name")))

  (define cli-path (find-executable-path "cardano-cli"))
  (unless cli-path (error "'cardano-cli' not found on PATH"))

  (define expect-path (find-executable-path "expect"))
  (unless expect-path (error "'expect' not found on PATH"))

  (define raw (with-output-to-string (lambda ()
                                       (unless (system* expect-path destroy-exp name)
                                         (error "Call to wallet attach failed.")))))

  (send (output "out") #t))

