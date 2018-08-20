#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "ph" ${gui.place-holder})
  (edge-out "ph" "out" "out")
  (edge-in "in" "ph" "in")

  (node "button" ${gui.button})
  (edge "button" "out" _ "ph" "place" 10)
  (mesg "button" "in" '(init . ((label . "Delete wallet ..."))))
  (mesg "button" "in" '(display . #t))

  (node "button-out" ${plumbing.option-transform})
  (mesg "button-out" "option"
        (match-lambda [(cons 'button #t) '(display . #t)]))
  (edge "button" "out" 'button "button-out" "in" _)

  (node "controls" ${gui.vertical-panel})
  (edge "controls" "out" _ "ph" "place" 20)
  (edge "button-out" "out" _ "controls" "in" _)

  (node "wallet-name-in" ${plumbing.identity})
  (edge-in "wallet-name" "wallet-name-in" "in")

  (node "wallet-name" ${plumbing.mux-demux})
  (mesg "wallet-name" "option"
        (match-lambda [(cons _ new-name)
                       (list (list* "text-field" 'set-value "")
                             (cons "match" new-name))]))
  (edge "wallet-name-in" "out" _ "wallet-name" "in" "init")

  (node "confirm-wallet-name" ${gui.text-field})
  (edge "confirm-wallet-name" "out" _ "controls" "place" 20)
  (mesg "confirm-wallet-name" "in" '(init . ((label . "Confirm name of wallet to delete"))))
  (edge "wallet-name" "out" "text-field" "confirm-wallet-name" "in" _)

  (node "names-match" ${plumbing.transform-ins-msgs})
  (mesg "names-match" "option"
        (match-lambda [(hash-table ("actual" actual)
                                   ("confirm" (cons 'text-field confirm)))

                       (define disable (list (cons 'set-enabled #f)))
                       (define enable (list (cons 'set-enabled #t)))

                       (cond
                         [(= 0 (string-length actual)) disable]
                         [(equal? actual confirm) enable]
                         [else disable])]))

  (edge "wallet-name" "out" "match" "names-match" "in" "actual")
  (edge "confirm-wallet-name" "out" 'text-field "names-match" "in" "confirm")

  (node "buttons" ${gui.horizontal-panel})
  (edge "buttons" "out" _ "controls" "place" 30)

  (node "confirm-button" ${gui.button})
  (edge "confirm-button" "out" _ "buttons" "place" 10)
  (mesg "confirm-button" "in" '(init . ((label . "Delete")
                                        (enabled . #f))))
  (edge "names-match" "out" _ "confirm-button" "in" _)

  (node "confirm-button-out" ${plumbing.demux})
  (mesg "confirm-button-out" "option"
        (match-lambda [(cons 'button #t)
                       (list (cons "delete" #t)
                             (cons "finish" #t))]))
  (edge "confirm-button" "out" 'button "confirm-button-out" "in" _)

  (node "cancel-button" ${gui.button})
  (edge "cancel-button" "out" _ "buttons" "place" 20)
  (mesg "cancel-button" "in" '(init . ((label . "Cancel"))))

  (node "finish" ${plumbing.mux-demux})
  (mesg "finish" "option"
        (lambda (_) (list (list* "button" 'display #t)
                          (cons "wallet-name" ""))))
  (edge "cancel-button" "out" 'button "finish" "in" "cancel")
  (edge "confirm-button-out" "out" "finish" "finish" "in" "confirm")
  (edge "finish" "out" "button" "button" "in" _)
  (edge "finish" "out" "wallet-name" "wallet-name" "in" "finish")

  (node "delete-out" ${plumbing.identity})
  (edge "confirm-button-out" "out" "delete" "delete-out" "in" _)
  (edge-out "delete-out" "out" "delete"))
