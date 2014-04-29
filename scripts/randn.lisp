;;;
;;; Rand(om)n(umber) script
;;; -----------------------
;;;
;;; Takes a seed from the
;;; user and replies with
;;; the randomly generated
;;; number.
;;;

(defun do-randn(chan sender arg)
  "Prints a random number. Usage: randn <seed>"
  (if(= (length arg) 0)(error "must specify at least one seed number"))
  (setq num (nth 0(txt:split arg #\Space)))
  (send-msg chan (format nil "~a: ~a" sender (random (parse-integer num)))))
