#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "details-button" ${gui.button})
  (edge "details-button" "out" _ "vp" "place" 10)
  (mesg "details-button" "in" '(init . ((label . "Used addresses"))))

  (node "details-toggle" ${plumbing.cycle-transform})
  (mesg "details-toggle" "option" (list (lambda (_) (list* "details" 'display #t))
                                        (lambda (_) (list* "no-details" 'display #t))))
  (edge "details-button" "out" 'button "details-toggle" "in" _)

  (node "details-choice" ${plumbing.demux})
  (edge "details-toggle" "out" _ "details-choice" "in" _)

  (node "maybe-details" ${gui.place-holder})
  (edge "maybe-details" "out" _ "vp" "place" 20)

  (node "no-details" ${gui.vertical-panel})
  (edge "no-details" "out" _ "maybe-details" "place" 10)
  (edge "details-choice" "out" "no-details" "no-details" "in" _)
  (mesg "no-details" "in" '(display . #t))

  (node "details" ${gui.vertical-panel})
  (edge "details" "out" _ "maybe-details" "place" 20)
  (edge "details-choice" "out" "details" "details" "in" _)

  (node "old-addr-0" ${gui.message})
  (edge "old-addr-0" "out" _ "details" "place" 10)
  (mesg "old-addr-0" "in" '(init . ((label . "lkjqwelrkjWFDKJSDLKFJLAKSDJFASLDKFJkljlksajdf"))))

  (node "old-addr-1" ${gui.message})
  (edge "old-addr-1" "out" _ "details" "place" 20)
  (mesg "old-addr-1" "in" '(init . ((label . "ZxcvzxnvcZC<MXNvzxc<VMxzcV<mxzcV<Mn")))))
