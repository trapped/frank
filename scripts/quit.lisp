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
      (setq line
        (if
          (= 0 (length arg))
          ""
          (format nil " : ~a" arg)))
      (format socket "QUIT~a~%" line))
    (send-msg chan (format nil "~a: user not authorized" sender))))
