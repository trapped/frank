;;;
;;; Processes the ERROR server message.
;;;

(defun process-error(line)
  "Processes the ERROR server message."
  (if quitting
    (progn
      (close socket)
      (quit))
    (format t ">> Error: ~a" (txt:get-text line))))
