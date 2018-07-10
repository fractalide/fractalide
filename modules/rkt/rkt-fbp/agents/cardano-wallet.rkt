#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  ; Menu
  (node "menu-bar" ${gui.menu-bar})
  (edge "menu-bar" "out" _ "frame" "in" _)

  (node "menu-file" ${gui.menu})
  (edge "menu-file" "out" _ "menu-bar" "place" 1)
  (mesg "menu-file" "in" #t)
  (mesg "menu-file" "option" "File")

  (node "menu-quit" ${gui.menu-item})
  (edge "menu-quit" "out" _ "menu-file" "place" 1)
  (mesg "menu-quit" "option" (cons 'close #t))
  (mesg "menu-quit" "in" '(init . ((label . "quit")
                                   (shortcut . #\q))))

  (node "menu-about" ${gui.menu})
  (edge "menu-about" "out" _ "menu-bar" "place" 3)
  (mesg "menu-about" "in" #t)
  (mesg "menu-about" "option" "About")

  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; node
  (node "node" ${hyperflow.node})
  (edge "node" "out" _ "vp" "place" 1)
  (edge "node" "menu" _ "menu-bar" "place" 2)
  (mesg "node" "in" '(init . ""))

  ;canvas
  (node "canvas" ${gui.canvas})
  (edge "canvas" "out" _ "vp" "place" 2)
  (node "rect" ${gui.canvas.rectangle})
  (edge "rect" "out" _ "canvas" "place" 1)
  (mesg "rect" "in" (cons 'init (vector 10 10 70 70)))
  (node "ell" ${gui.canvas.ellipse})
  (edge "ell" "out" _ "canvas" "place" 2)
  (mesg "ell" "in" (cons 'init (vector 10 10 50 50)))
  (node "text" ${gui.canvas.text})
  (edge "text" "out" _ "canvas" "place" 3)
  (mesg "text" "in" (cons 'init (vector "Hello Canvas!" 25 100)))

  (node "delay" ${delayer})
  (edge "delay" "out" _ "rect" "in" _)
  (mesg "delay" "in" '(delete . #t))
  )

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
