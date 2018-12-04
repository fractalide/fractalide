#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)
(require racket/runtime-path)

(define-runtime-path address-exp "./address.exp")

(define-agent
  #:input '("name" "passwd" "account-index" "address-index")
  #:output '("out")
  (define name (recv (input "name")))
  (define passwd (recv (input "passwd")))
  (define account-index (recv (input "account-index")))
  (define address-index (recv (input "address-index")))

  (define cli-path (find-executable-path "cardano-cli"))
  (unless cli-path (error "'cardano-cli' not found on PATH"))

  (define expect-path (find-executable-path "expect"))
  (unless expect-path (error "'expect' not found on PATH"))

  (define raw (with-output-to-string (lambda ()
                                       (unless (equal? 0 (system*/exit-code expect-path address-exp
                                                                            name passwd account-index address-index))
                                         (error "Call to wallet address failed.")))))
  (define res (string-trim (last (string-split raw "\n"))))

  (send (output "out") res))

