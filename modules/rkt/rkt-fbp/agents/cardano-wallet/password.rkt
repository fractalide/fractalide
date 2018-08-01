#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "ph" ${gui.place-holder})
  (edge-out "ph" "out" "out")
  (edge-in "in" "ph" "in")

  (node "change-button" ${gui.button})
  (edge "change-button" "out" _ "ph" "place" 10)
  (mesg "change-button" "in" '(init . ((label . "Change password ..."))))
  (mesg "change-button" "in" '(display . #t))

  (node "change-button-out" ${plumbing.option-transform})
  (mesg "change-button-out" "option"
        (match-lambda [(cons 'button #t) '(display . #t)]))
  (edge "change-button" "out" 'button "change-button-out" "in" _)

  (node "change-controls" ${gui.vertical-panel})
  (edge "change-controls" "out" _ "ph" "place" 20)
  (edge "change-button-out" "out" _ "change-controls" "in" _)

  (node "new-password" ${gui.text-field})
  (edge "new-password" "out" _ "change-controls" "place" 10)
  (mesg "new-password" "in" '(init . ((label . "New password")
                                      (style . (single password)))))

  (node "confirm-password" ${gui.text-field})
  (edge "confirm-password" "out" _ "change-controls" "place" 20)
  (mesg "confirm-password" "in" '(init . ((label . "Confirm new password")
                                          (style . (single password)))))

  (node "initialize-password" ${plumbing.mux-demux})
  (mesg "initialize-password" "option"
        (match-lambda [(cons _ password)
                       (list (list* "new-password" 'set-value password)
                             (list* "confirm-password" 'set-value password))]))
  (edge "initialize-password" "out" "new-password" "new-password" "in" _)
  (edge "initialize-password" "out" "confirm-password" "confirm-password" "in" _)

  (node "passwords-match" ${plumbing.transform-ins-msgs})
  (mesg "passwords-match" "option"
        (match-lambda [(hash-table ("new" (cons 'text-field new))
                                   ("confirm" (cons 'text-field confirm)))

                       (define disable (list (list* "valid" 'set-enabled #f)
                                             (list* "password" "")))
                       (define enable (list (list* "valid" 'set-enabled #t)
                                            (list* "password" new)))

                       (cond
                         [(= 0 (string-length new)) disable]
                         [(equal? new confirm) enable]
                         [else disable])]))

  (edge "new-password" "out" 'text-field "passwords-match" "in" "new")
  (edge "confirm-password" "out" 'text-field "passwords-match" "in" "confirm")

  (node "buttons" ${gui.horizontal-panel})
  (edge "buttons" "out" _ "change-controls" "place" 30)

  (node "confirm-button" ${gui.button})
  (edge "confirm-button" "out" _ "buttons" "place" 10)
  (mesg "confirm-button" "in" '(init . ((label . "Change")
                                        (enabled . #f))))

  (node "confirm-button-out" ${plumbing.demux})
  (mesg "confirm-button-out" "option"
        (match-lambda [(cons 'button #t)
                       (list (list* "set-password" 'button #t)
                             (cons "finish" #t))]))
  (edge "confirm-button" "out" 'button "confirm-button-out" "in" _)

  (node "cancel-button" ${gui.button})
  (edge "cancel-button" "out" _ "buttons" "place" 20)
  (mesg "cancel-button" "in" '(init . ((label . "Cancel"))))

  (node "finish" ${plumbing.mux-demux})
  (mesg "finish" "option"
        (lambda (_) (list (list* "change-button" 'display #t)
                          (cons "initialize-password" ""))))
  (edge "cancel-button" "out" 'button "finish" "in" "cancel")
  (edge "confirm-button-out" "out" "finish" "finish" "in" "confirm")
  (edge "finish" "out" "change-button" "change-button" "in" _)
  (edge "finish" "out" "initialize-password" "initialize-password" "in" "finish")

  (node "set-password" ${cardano-wallet.set-password})
  (edge "confirm-button-out" "out" "set-password" "set-password" "in" _)
  (edge-out "set-password" "out" "password")

  (node "passwords-match-out" ${plumbing.demux})
  (edge "passwords-match" "out" _ "passwords-match-out" "in" _)
  (edge "passwords-match-out" "out" "valid" "confirm-button" "in" _)
  (edge "passwords-match-out" "out" "password" "set-password" "password" _))
