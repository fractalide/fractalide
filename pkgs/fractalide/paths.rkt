#lang racket

(provide node-name->path fractal-path
         fractal-exists? node-path node-exists?)

(define fract-env (getenv "FRACTALIDE"))

; String -> Path
(define (node-name->path node-name)
  (string->path (string-join (string-split node-name "_") "/")))

; String -> Path
(define (fractal-path fractal-name)
  (simplify-path (build-path fract-env 'up "fractals" fractal-name)))

; String -> Boolean
(define (fractal-exists? fractal-name)
  (directory-exists? (fractal-path fractal-name)))

; String String String -> Path
(define (node-path fractal-name language node-name)
  (if (string=? fractal-name "fractalide")
      (build-path fract-env "nodes" language (node-name->path node-name))
      (build-path (fractal-path fractal-name) "nodes" language
                  (node-name->path node-name))))

; String String String -> Boolean
(define (node-exists? fractal language node-name)
  (directory-exists? (node-path fractal language node-name)))
