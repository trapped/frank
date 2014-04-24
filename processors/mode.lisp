;;;
;;; Processes the MODE server message.
;;;

(defun process-mode(line)
  (if (= (length joined) 0) (send-join)))
