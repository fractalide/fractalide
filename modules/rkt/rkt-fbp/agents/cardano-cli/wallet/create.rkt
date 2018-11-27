#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("name" "passwd")
  #:output '("out")
  (define name (recv (input "name")))
  (define passwd (recv (input "passwd")))

  (define cli-path (find-executable-path "cardano-cli"))
  (unless cli-path (error "'cardano-cli' not found on PATH"))

  (define expect-path (find-executable-path "expect"))
  (unless expect-path (error "'expect' not found on PATH"))

  (define raw (with-output-to-string (lambda ()
                                       (unless (equal? 0 (system*/exit-code expect-path "./agents/cardano-cli/wallet/create.exp" name passwd))
                                         (error "Call to blockhain list failed.")))))
  (define res (string-trim (car (string-split(cadr (string-split raw "english: ")) "\n"))))
  ; Remove the terminal color code
  (set! res (substring res 4))

  (send (output "out") res))

