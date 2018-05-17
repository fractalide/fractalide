#lang racket/base

(require racket/match
         racket/list
         (prefix-in class: racket/class))

(require fractalide/modules/rkt/rkt-fbp/agent)

(provide (all-defined-out))

(define (area-manage area msg output output-array)
  (match msg
    [(cons 'set-stretchable-width (? boolean? b))
     (class:send area stretchable-width b)
     #t]
    [(cons 'set-stretchable-height (? boolean? b))
     (class:send area stretchable-height b)
     #t]
    [(cons 'get-stretchable-width act)
     (send-action output output-array (cons act (class:send area stretchable-width)))
     #t]
    [(cons 'get-stretchable-height act)
     (send-action output output-array (cons act (class:send area stretchable-height)))
     #t]
    [(cons 'set-min-width width)
     (class:send area min-width width)
     #t]
    [(cons 'get-min-width act)
     (send-action output output-array (cons act (class:send area min-width)))
     #t]
    [(cons 'set-min-height height)
     (class:send area min-height height)
     #t]
    [(cons 'get-min-height act)
     (send-action output output-array (cons act (class:send area min-height)))
     #t]
    [(cons 'get-top-level-window act)
     (send-action output output-array (cons act (class:send area get-top-level-window)))
     #t]
    [(cons 'get-parent act)
     (send-action output output-array (cons act (class:send area get-parent)))
     #t]
    [(cons 'get-graphical-min-size act)
     (send-action output output-array (cons act (class:send area get-graphical-min-size)))
     #t]
    [else #f]))

(define (subarea-manage area msg output output-array)
  (match msg
    [(cons 'set-horiz-margin marge)
     (class:send area horiz-margin marge)
     #t]
    [(cons 'get-horiz-margin act)
     (send-action output output-array (cons act (class:send area horiz-margin)))
     #t]
    [(cons 'set-vert-margin marge)
     (class:send area vert-margin marge)
     #t]
    [(cons 'get-vert-margin act)
     (send-action output output-array (cons act (class:send area vert-margin)))
     #t]
    [else #f]))

(define (window-manage window msg output output-array)
  (match msg
    [(cons 'set-accept-drop-files accept)
     (class:send window accept-drop-files accept)
     #t]
    [(cons 'get-accept-drop-files act)
     (send-action output output-array (cons act (class:send window accept-drop-files)))
     #t]
    [(cons 'get-client->screen (vector act x y))
     (send-action output output-array (cons act (class:send window client->screen x y)))
     #t]
    [(cons 'get-screen->client (vector act x y))
     (send-action output output-array (cons act (class:send window screen->client x y)))
     #t]
    [(cons 'set-enable enable)
     (class:send window set-enable enable)
     #t]
    [(cons 'focus #t)
     (class:send window focus)
     #t]
    [(cons 'get-client-size act)
     (send-action output output-array (cons act (class:send window get-client-size)))
     #t]
    [(cons 'get-cursor act)
     (send-action output output-array (cons act (class:send window get-cursor)))
     #t]
    [(cons 'get-height act)
     (send-action output output-array (cons act (class:send window get-height)))
     #t]
    [(cons 'get-label act)
     (send-action output output-array (cons act (class:send window get-label)))
     #t]
    [(cons 'get-plain-label act)
     (send-action output output-array (cons act (class:send window get-plain-label)))
     #t]
    [(cons 'get-size act)
     (send-action output output-array (cons act (class:send window get-size)))
     #t]
    [(cons 'get-width act)
     (send-action output output-array (cons act (class:send window get-width)))
     #t]
    [(cons 'get-x act)
     (send-action output output-array (cons act (class:send window get-x)))
     #t]
    [(cons 'get-y act)
     (send-action output output-array (cons act (class:send window get-y)))
     #t]
    [(cons 'has-focus? act)
     (send-action output output-array (cons act (class:send window has-focus?)))
     #t]
    [(cons 'is-enabled? act)
     (send-action output output-array (cons act (class:send window is-enabled?)))
     #t]
    [(cons 'popup-menu (vector menu x y))
     (class:send window popup-menu menu x y)
     #t]
    [(cons 'refresh #t)
     (class:send window refresh)
     #t]
    [(cons 'set-cursor cursor)
     (class:send window set-cursor cursor)
     #t]
    [(cons 'set-label label)
     (class:send window set-label label)
     #t]
    [(cons 'show b)
     (class:send window show b)
     #t]
    [(cons 'wrap-pointer (cons x y))
     (class:send window wrap-pointer x y)
     #t]
    [else #f]))

(define (area-container-manage area msg output output-array)
  (match msg
    [(cons 'set-border margin)
     (class:send area set-border margin)
     #t]
    [(cons 'get-border act)
     (send-action output output-array (cons act (class:send area border)))
     #t]
    [(cons 'container-size info)
     (class:send area container-size info)
     #t]
    [(cons 'get-alignment act)
     (send-action output output-array (cons act (class:send area get-alignment)))
     #t]
    [(cons 'set-alignment (cons horiz vert))
     (class:send area set-alignment horiz vert)
     #t]
    [(cons 'get-spacing act)
     (send-action output output-array (cons act (class:send area spacing)))
     #t]
    [(cons 'set-spacing spacing)
     (class:send area set-spacing spacing)
     #t]
    [(cons 'reflow-container #t)
     (class:send area reflow-container)
     #t]
    [else #f]))

(define (list-control-manage area msg output output-array)
  (match msg
    [(cons 'append elem)
     (class:send area append elem)
     #t]
    [(cons 'clear #t)
     (class:send area clear)
     #t]
    [(cons 'delete elem)
     (class:send area delete elem)
     #t]
    [(cons 'find-string (cons s act))
     (send-action output output-array (cons act (class:send area find-string s)))
     #t]
    [(cons 'get-number act)
     (send-action output output-array (cons act (class:send area get-number)))
     #t]
    [(cons 'get-string (cons s act))
     (send-action output output-array (cons act (class:send area get-string s)))
     #t]
    [(cons 'get-string-selection act)
     (send-action output output-array (cons act (class:send area get-string-selection)))
     #t]
    [(cons 'set-selection n)
     (class:send area set-selection n)
     #t]
    [(cons 'set-string-selection s)
     (class:send area set-string-selection s)
     #t]
    [else #f]))

(define (with-event super-class input)
  (class:class super-class
    ; (class:define/override (on-subwindow-event item event)
    ;                        (send (input "in") (cons (class:send event get-event-type) event))
    ;                        #f)
    (class:define/override (on-subwindow-char item event)
                           (send (input "in") (cons 'key event))
                           #f)
    (class:define/override (on-drop-file path)
      (send (input "in") (cons 'drop-file path)))
    (class:define/override (on-focus on?)
      (send (input "in") (cons 'focus on?)))
    (class:define/override (on-subwindow-focus recv on?)
                           (send (input "in") (cons 'subwindow-focus on?))
                           #f)
    (class:define/override (on-move x y)
      (send (input "in") (cons 'move (cons x y))))
    (class:define/override (on-size x y)
      (send (input "in") (cons 'size (cons x y))))
    (class:define/override (on-superwindow-enable b?)
      (send (input "in") (cons 'superwindow-enable b?)))
    (class:define/override (on-superwindow-show b?)
      (send (input "in") (cons 'superwindow-show b?)))
    (class:super-new)))


(define (manage acc msg input output output-array create process-msg)
  ; If no acc, create a empty list
  (set! acc (if acc acc (cons 'init (list))))
  (if (and (cons? acc) (eq? (car acc) 'init))
      (begin
        ; true -> widget in creation
        (if (eq? (car msg) 'init)
            ; True -> create widget and receive it
            ;      -> process the list
            (begin
              ; create the widget
              (send (output "out") (cons 'init (create input (cdr msg))))
              (let ([widget (recv (input "acc"))])
                (for ([m (cdr acc)])
                  (process-msg m widget input output output-array))
                widget))
            ; False -> add to the list
            (cons 'init (cons msg (cdr acc)))))
      ; false -> already created
      (begin
        (process-msg msg acc input output output-array)
        acc)))
