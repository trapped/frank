;;;
;;; Processes the NOTICE server message.
;;;

(defun process-notice(line)
  (format t ">> Notice: ~a~%" (txt:get-text line))
  (send-nick)
  (send-user))
