;;;
;;; Processes the PRIVMSG server message.
;;;

(defun process-privmsg(line)
  "Processes received PRIVMSG messages."
  (setq text (string-downcase (txt:get-text line)))
  (handler-case
    (progn
      (setq prefix (format nil "~a: " nick))
      (cond
        ((string= text prefix :end1 (length prefix))(make-thread (lambda() (progn(thread-yield)(on-command line nil)))))
        ((char= (nth 0 (coerce line 'list)) #\.)    (make-thread (lambda() (progn(thread-yield)(on-command line t)))))))
    (condition (exc) (print exc)))
  (format t "~a <- ~a: ~a~%" (txt:get-privmsg-recp line) (txt:get-sender line) (txt:get-text line))))

(defun on-command(line is-alias)
  "Finds and executes received commands."
  (setq prefix
    (if is-alias
      "."
      (format nil "~a: " nick)))
  (print 1)
  (setq text (subseq (txt:get-text line) (length prefix)))
  (print 2)
  (setq cmd (nth 0 (split text #\Space)))
  (print 3)
  (setq raw-arg (subseq text (+ (length prefix) (length cmd) 1)))
  (print 4)
  (setq sym (find-symbol (format nil "DO-~a" (string-upcase cmd))))
  (print 5)
  (handler-case
    (if sym
      (funcall (symbol-function sym) (txt:get-privmsg-recp line) (txt:get-sender line) raw-arg)
      (if (not is-alias) (send-msg (txt:get-privmsg-recp line) (format nil "~a: unknown command '~a' :(" (txt:get-sender line) cmd))))
    (condition (exc) (send-msg (txt:get-privmsg-recp line) (format nil "~a: error processing the command ('~a') :(" (txt:get-sender line) exc))))
  (print 6))
