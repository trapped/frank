;;;
;;; Quit script
;;; -----------
;;;
;;; Quits the connection
;;; with the IRC server
;;; and exits.
;;;

(defun do-quit(chan sender arg)
  "Disconnects from the server. Usage: quit [<quit message>]"
  (if (txt:smember sender authorized-users)
    (progn
      (setf quitting t)
      (format socket "QUIT :~a~%" arg))
    (send-msg chan (format nil "~a: user not authorized" sender))))
