;;;
;;; Processes the MODE server message.
;;;

(defun process-mode(line)
  (if
    (not identified)
    (progn
      (send-msg "NickServ" (format nil "identify ~a" password))
      (setf identified t)))
  (if
    (= (length joined) 0)
    (send-join)))
