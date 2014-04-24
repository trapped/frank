;;;
;;; Processes the JOIN server message.
;;;

(defun process-join(line)
  "Processes received JOIN messages."
  (setq text (txt:get-text line))
  (concatenate 'list '(text) joined)
  (format t ">> Joined channel ~a~%" (txt:get-text line)))
