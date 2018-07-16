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

  (node "app" ${gui.horizontal-panel})
  (edge "app" "out" _ "frame" "in" _)

  (node "sidebar" ${cardano-wallet.menu})
  (edge "sidebar" "out" _ "app" "place" 10)

  (node "stack" ${gui.place-holder})
  (edge "stack" "out" _ "app" "place" 20)

  (node "welcome" ${cardano-wallet.welcome})
  (edge "welcome" "out" _ "stack" "place" 30)
  (mesg "welcome" "in" '(display . #t)))

(module+ main
  (require syntax/location)

  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/fvm)

  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (quote-module-path ".."))
    (define a-graph (make-graph (node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
