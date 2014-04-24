;;;
;;; Processes the PRIVMSG server message.
;;;

(defun process-privmsg(line)
  "Processes received PRIVMSG messages."
  (setq text (string-downcase (txt:get-text line)))
  (setq prefix (string-downcase (format nil "~a: " nick)))
  (cond
    ((/=
      (progn
        (setq res (string>= text prefix))
        (if (not res) 0 res))
      0)
      (if
        (string= text prefix :end1 (length prefix))
        (read-cmd line)))
    (t (format t "~a <- ~a: ~a~%" (txt:get-privmsg-recp line) (txt:get-sender line) (txt:get-text line)))))
