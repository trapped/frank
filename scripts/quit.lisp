;;;
;;; Quit script
;;; -----------
;;;
;;; Quits the connection
;;; with the IRC server
;;; and exits.
;;;

(defun do-quit(chan sender message)
  "Disconnects from the server"
  (if (txt:smember sender authorized-users)
    (progn
      (setf quitting t)
      (format socket "QUIT :~a~%" message))
    (send-msg chan (format nil "~a: user not authorized" sender))))
