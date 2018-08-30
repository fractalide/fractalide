#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in array port
    (recv (input "in")))
