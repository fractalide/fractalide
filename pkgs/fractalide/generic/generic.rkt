#lang typed/racket

(provide write-generics-files)
(require "license.rkt")
(require "contributing.rkt")
(require "readme.rkt")

(: write-generics-files (Path -> Void))
(define (write-generics-files path)
  (write-generic-file path "LICENSE")
  (write-generic-file path "CONTRIBUTING.md")
  (write-generic-file path "README.md"))

(: write-generic-file (Path String -> Void))
(define (write-generic-file path filename)
  (with-output-to-file (build-path path filename) #:exists 'replace 
    (lambda () (display (cond
                          [(string=? filename "LICENSE") license-template]
                          [(string=? filename "CONTRIBUTING.md") contributing-template]
                          [(string=? filename "README.md") readme-template])))))

