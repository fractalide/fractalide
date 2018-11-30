#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.wcreate})

(define-agent
  #:input '("name" "pwd" "pwd-cfm" "next") ; in array port
  #:output '("error" "name" "pwd" "next" "destroy" "attach") ; out port
  #:output-array '("clean-field")
  (define acc (try-recv (input "acc")))
  (unless acc
    (set! acc (wcreate "" "" "")))

  (define name (try-recv (input "name")))
  (when name
    (set-wcreate-name! acc (cdr name)))

  (define pwd (try-recv (input "pwd")))
  (when pwd
    (set-wcreate-pwd! acc (cdr pwd)))

  (define pwd-cfm (try-recv (input "pwd-cfm")))
  (when pwd-cfm
    (set-wcreate-pwd-cfm! acc (cdr pwd-cfm)))

  (define next (try-recv (input "next")))
  (when next
    (cond
      [(not (non-empty-string? (wcreate-name acc)))
       (send (output "error") '(set-label . "Empty name"))]
      [(not (non-empty-string? (wcreate-pwd acc)))
       (send (output "error") '(set-label . "Empty password"))]
      [(not (string=? (wcreate-pwd acc) (wcreate-pwd-cfm acc)))
       (send (output "error") '(set-label . "Passwords missmatch"))]
      [else
       (send (output "name") (wcreate-name acc))
       (send (output "pwd") (wcreate-pwd acc))
       (send (output "next") (cons 'display #t))
       (send (output "destroy") (wcreate-name acc))
       (send (output "attach") (wcreate-name acc))
       (set-wcreate-pwd! acc "")
       (set-wcreate-pwd-cfm! acc "")
       (for ([(k v) (output-array "clean-field")])
         (send v `(set-value . ,"")))]))

  (send (output "acc") acc))
