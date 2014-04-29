;;;
;;; Script-reloading script
;;; -----------------------
;;;
;;; Reloads scripts and processors.
;;;

(defun do-reload(chan sender arg)
  "Reloads core, scripts and processors. Usage: reload"
  (load "txtproc.lisp")
  (loop
  for file in (directory "./processors/*")
  do(load (namestring file)))
  (send-msg chan (format nil "~a: reloaded processors" sender))
  (loop
  for file in (directory "./scripts/*")
  do(load (namestring file)))
  (send-msg chan (format nil "~a: reloaded scripts" sender)))
