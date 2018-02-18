#lang typed/racket

(require "names.rkt")

(require typed-map)

(provide insert-raw-into-default)

(: grep-file (Path String -> (Listof (Pairof Nonnegative-Fixnum String))))
(define (grep-file path pattern)
  (define lines (file->lines path))
  (define line-numbers(range 1 (add1 (length lines))))
  (define pairs (map cons line-numbers lines))
  (define does-match? (λ ([n : (Pairof Nonnegative-Fixnum String)]) (regexp-match pattern (cdr n))))
  (filter does-match? pairs))

(: insert-raw-into-default (Path String String String -> Void))
(define (insert-raw-into-default path pattern comp-name comp-type)
  (define nix-attr (if (string=? comp-type "edges")
                       (edge-nix-attr comp-name)
                       (node-nix-attr comp-name)))
  (define line-number (grep-file path pattern))
  (define temp-file (path-add-extension path #"~~" #"."))
  (define proper-line-number (+ 2 (car (car line-number))))
  (insert-line-in-file path temp-file nix-attr proper-line-number)
  (delete-rename-files path temp-file))

(: delete-rename-files (Path Path -> Void))
(define (delete-rename-files old new)
  (delete-file old)
  (rename-file-or-directory new old))

(: insert-line (String Integer -> Void))
(define (insert-line line line-number)
  (for ([l (in-lines)]
        [i (in-naturals)])
    (when (= i line-number)
      (displayln line))
    (displayln l)))

(: insert-line-in-file (Path Path String Integer -> Void))
(define (insert-line-in-file file-in file-out line line-number)
  (with-output-to-file file-out
    (λ ()
      (with-input-from-file file-in
        (λ ()
          (insert-line line line-number))))))