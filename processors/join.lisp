;;;
;;; Processes the JOIN server message.
;;;

(defun process-join(line)
  "Processes received JOIN messages."
  (setq text (txt:get-text line))
  (setf joined (concatenate 'list (list text) joined))
  (setq pref
    (progn
      (setq snd (txt:get-sender line))
      (if
        (string= snd nick)
        "Joined"
        (format nil "~a joined" snd))))
  (format t ">> ~a channel ~a~%" pref (txt:get-text line)))
