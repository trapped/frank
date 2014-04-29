;;;
;;; Help script
;;; -----------
;;;
;;; Prints a command's documentation.
;;;

(defun do-help(chan sender arg)
  "Gives help about commands. Usage: help <command>"
  (if(= (length arg) 0)(error "must specify a command"))
  (setq hcmd (nth 0 (txt:split arg #\Space)))
  (send-msg chan
    (format nil "~a: ~a" sender
      (documentation
        (symbol-function
          (if
            (not (find-symbol
              (format nil "DO-~a" (string-upcase hcmd))))
            (progn
              (send-msg chan (format nil "~a: unknown command" sender))
              (return-from do-help))
            (find-symbol
              (format nil "DO-~a" (string-upcase hcmd)))))
        'function))))
