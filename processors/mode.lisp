;;;
;;; Processes the MODE server message.
;;;

(defun process-mode(line)
  (if
    (and (not identified) (/= 0 (length password)))
    (progn
      (send-msg "NickServ" (format nil "identify ~a" password))
      (setf identified t)))
  (if
    (= (length joined) 0)
    (send-join)))

(defun copy-stream (in out)
   (loop for line = (read-line in nil nil)
         while line
         do (write-line line out)))
