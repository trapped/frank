;;;
;;; Processes the PING server message.
;;;

(defun process-ping(line)
  (format socket "PONG ~a~%"  (subseq line 5)))
