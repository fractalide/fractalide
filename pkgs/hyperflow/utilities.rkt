#lang racket

(require racket/contract)

(provide/contract
 (data-directory (-> path-string?))
 (preferences-file (-> path-string?))
 (get-pref-dir (-> path-string?))
 (put-pref (-> symbol? any/c any/c))
 (get-pref (-> symbol? any/c any/c)))

(define (get-pref-dir)
  (if (eq? 'windows (system-type 'os))
      (let ([pref-dir (getenv "LOCALAPPDATA")])
        (if pref-dir
            (string->path pref-dir)
            (find-system-path 'pref-dir)))
      (find-system-path 'pref-dir)))

(define the-data-directory #f)

(define (data-directory)
  (unless the-data-directory
    (let ((dir (get-pref-dir)))
      (let ((pref-dir (build-path dir "Hyperflow")))
        (make-directory* pref-dir)
        (set! the-data-directory pref-dir))))
  the-data-directory)

(define the-preferences-file #f)

(define (preferences-file)
  (unless the-preferences-file
    (set! the-preferences-file
          (build-path (data-directory) "HyperflowPrefs.rktd")))
  the-preferences-file)

(define (put-pref name value)
  (put-preferences (list name)
                   (list value) 
                   (lambda (p) (error 'lock-fail "Failed to get the pref file lock" p))
                   (preferences-file)))

(define (get-pref name fail-thunk)
  (get-preference name fail-thunk 'timestamp (preferences-file)))
