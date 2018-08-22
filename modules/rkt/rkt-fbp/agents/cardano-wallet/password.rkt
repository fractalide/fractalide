#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (with-node-name "ph" (node ${gui.place-holder})
                  (edge-out "out" "out")
                  (edge-in "in" "in"))

  (with-node-name "change-button" (node ${gui.button})
                  (edge "out" "ph" "place" #:selection 10)
                  (mesg "in" '(init . ((label . "Change password ..."))))
                  (mesg "in" '(display . #t)))

  (with-node-name "change-button-out" (node ${plumbing.option-transform})
                  (mesg "option" (match-lambda [(cons 'button #t) '(display . #t)])))
  (edge "change-button" "out" 'button "change-button-out" "in" _)

  (with-node-name "change-controls" (node ${gui.vertical-panel})
                  (edge "out" "ph" "place" #:selection 20))
  (edge "change-button-out" "out" _ "change-controls" "in" _)

  (with-node-name "new-password" (node ${gui.text-field})
                  (edge "out" "change-controls" "place" #:selection 10)
                  (mesg "in" '(init . ((label . "New password")
                                       (style . (single password))))))

  (with-node-name "confirm-password" (node ${gui.text-field})
                  (edge "out" "change-controls" "place" #:selection 20)
                  (mesg "in" '(init . ((label . "Confirm new password")
                                       (style . (single password))))))

  (with-node-name "initialize-password" (node ${plumbing.mux-demux})
                  (edge "out" #:selection "new-password" "new-password" "in")
                  (edge "out" #:selection "confirm-password" "confirm-password" "in"))

  (mesg "initialize-password" "option" (match-lambda
                    [(cons _ password)
                     (list (list* "new-password" 'set-value password)
                           (list* "confirm-password" 'set-value password))]))

  (with-node-name "passwords-match" (node ${plumbing.transform-ins-msgs})
                  (mesg "option" (match-lambda
                    [(hash-table ("new" (cons 'text-field new))
                                 ("confirm" (cons 'text-field confirm)))

                     (define disable (list (list* "valid" 'set-enabled #f)
                                           (list* "password" "")))
                     (define enable (list (list* "valid" 'set-enabled #t)
                                          (list* "password" new)))

                     (cond
                       [(= 0 (string-length new)) disable]
                       [(equal? new confirm) enable]
                       [else disable])])))

  (edge "new-password" "out" 'text-field "passwords-match" "in" "new")
  (edge "confirm-password" "out" 'text-field "passwords-match" "in" "confirm")

  (with-node-name "buttons" (node ${gui.horizontal-panel})
                  (edge "out" "change-controls" "place" #:selection 30))

  (with-node-name "confirm-button" (node ${gui.button})
                  (edge "out" "buttons" "place" #:selection 10)
                  (mesg "in" '(init . ((label . "Change")
                                       (enabled . #f)))))

  (with-node-name "confirm-button-out" (node ${plumbing.demux})
                  (mesg "option" (match-lambda
                    [(cons 'button #t)
                     (list (list* "set-password" 'button #t)
                           (cons "finish" #t))])))
  (edge "confirm-button" "out" 'button "confirm-button-out" "in" _)

  (with-node-name "cancel-button" (node ${gui.button})
                  (edge "out" "buttons" "place" #:selection 20)
                  (mesg "in" '(init . ((label . "Cancel")))))

  (with-node-name "finish" (node ${plumbing.mux-demux})
                  (mesg "option" (lambda (_)
                    (list (list* "change-button" 'display #t)
                          (cons "initialize-password" "")))))
  (edge "cancel-button" "out" 'button "finish" "in" "cancel")
  (edge "confirm-button-out" "out" "finish" "finish" "in" "confirm")
  (edge "finish" "out" "change-button" "change-button" "in" _)
  (edge "finish" "out" "initialize-password" "initialize-password" "in" "finish")

  (node "set-password" ${cardano-wallet.set-password})
  (edge "confirm-button-out" "out" "set-password" "set-password" "in" _)
  (edge-out "set-password" "out" "password")

  (with-node-name "passwords-match-out" (node ${plumbing.demux})
                  (edge "out" #:selection "valid" "confirm-button" "in")
                  (edge "out" #:selection "password" "set-password" "password"))
  (edge "passwords-match" "out" _ "passwords-match-out" "in" _))
