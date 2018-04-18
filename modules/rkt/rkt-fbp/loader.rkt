#lang racket/base

(provide load-agent)

(define (load-agent path)
  (let ([agt (dynamic-require path 'agt)])
    agt))
