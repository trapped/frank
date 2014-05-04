;;;
;;; Processes the PRIVMSG server message.
;;;

(defun process-privmsg(line)
  "Processes received PRIVMSG messages."
  (setq text (string-downcase (txt:get-text line)))
  (setq first-char (nth 0 (coerce text 'list)))
  (progn
    (setq prefix (format nil "~a: " (string-downcase nick)))
    (cond
      ((progn
         (setq res (string>= text prefix))
         (if
           (not res)
           (setq res 0))
         (>=
           res
           (length prefix)))
        (make-thread (lambda() (progn(thread-yield)(on-command line nil)))))
      ((char= first-char #\.)
        (make-thread (lambda() (progn(thread-yield)(on-command line t)))))))
  (format t "~a <- ~a: ~a~%" (txt:get-privmsg-recp line) (txt:get-sender line) (txt:get-text line)))

(defun on-command(line is-alias)
  "Finds and executes received commands."
  (setq prefix
    (if is-alias
      "."
      (format nil "~a: " (string-downcase nick))))
  (setq text (subseq (txt:get-text line) (length prefix)))
  (setq cmd (nth 0 (txt:split text #\Space)))
  (setq raw-arg "")
  (ignore-errors
    (setq raw-arg (subseq text (+ (length cmd) 1))))
  (setq sym (find-symbol (format nil "DO-~a" (string-upcase cmd))))
  (if (= 0 (length (string-trim " " text)))(return-from on-command))
  (handler-case
    (if sym
      (funcall (symbol-function sym) (txt:get-privmsg-recp line) (txt:get-sender line) raw-arg)
      (if (not is-alias) (send-msg (txt:get-privmsg-recp line) (format nil "~a: unknown command '~a' :(" (txt:get-sender line) cmd))))
    (condition (exc) (send-msg (txt:get-privmsg-recp line) (format nil "~a: ~a :(" (txt:get-sender line) exc)))))
