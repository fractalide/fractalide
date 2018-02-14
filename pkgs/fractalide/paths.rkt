#lang typed/racket

(provide node-name->path fractal-path
         fractal-exists? node-path node-exists?)

(define fract-env (assert (getenv "FRACTALIDE")))

(: node-name->path : [String -> Path])
(define (node-name->path node-name)
  (string->path (string-join (string-split node-name "_") "/")))

(: fractal-path : [String -> Path])
(define (fractal-path fractal-name)
  (simplify-path (build-path fract-env 'up "fractals" fractal-name)))

(: fractal-exists? : [String -> Boolean])
(define (fractal-exists? fractal-name)
  (directory-exists? (fractal-path fractal-name)))

(: node-path : [String String String -> Path])
(define (node-path fractal-name language node-name)
  (if (string=? fractal-name "fractalide")
      (build-path fract-env "nodes" language (node-name->path node-name))
      (build-path (fractal-path fractal-name) "nodes" language
                  (node-name->path node-name))))

(: node-exists? : [String String String -> Boolean])
(define (node-exists? fractal language node-name)
  (directory-exists? (node-path fractal language node-name)))

