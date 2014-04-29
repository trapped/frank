;;;
;;; Quotes scripts
;;; --------------
;;;
;;; Reads a quote and eventually
;;; adds it to a file containing
;;; a list of quotes.
;;;

(defun do-getquote(chan sender arg)
  "Gets a quote from the channel's quotes file. Usage: getquote [[#]<number>]"
  (setq filename (format nil "~a.quotes" chan))
  (setq linec
    (handler-case
      (lines-count filename)
      (condition() 0)))
  (if
    (= linec 0)
    (return-from do-getquote
      (send-msg chan (format nil "~a: no quotes for this channel yet" sender))))
  (setq randq (random linec))
  (setq quoid (substitute #\null #\# (nth 0 (txt:split arg #\Space))))
  (if
    (= (length quoid) 0)
    (return-from do-getquote
      (send-msg chan (format nil "~a: #~d: ~a" sender randq
        (handler-case
          (progn
            (setq exquote (get-line-by-num filename randq))
            (return-from do-getquote (send-msg chan (format nil "~a: ~a" sender (subseq exquote (+ 1 (txt:get-occurrence exquote #\> 2)))))))
          (condition() (return-from do-getquote (send-msg chan (format nil "~a: no quotes for this channel yet" sender)))))))))
  (progn
    (handler-case
        (setq reqnum (parse-integer quoid))
      (condition(exc) (return-from do-getquote (send-msg chan (format nil "~a: invalid quote id" sender)))))
    (handler-case
      (setq exquote (get-line-by-num filename reqnum))
      (condition() (return-from do-getquote (send-msg chan (format nil "~a: invalid quote id" sender)))))
    (send-msg chan (format nil "~a: ~a" sender (subseq exquote (+ 1 (txt:get-occurrence exquote #\> 2)))))))

(defun do-addquote(chan sender arg)
  "Adds a quote to the channel's quotes file. Usage: addquote <text>"
  (setq filename (format nil "~a.quotes" chan))
  (if
    (= (length (substitute #\null #\Space arg)) 0)
    (return-from do-addquote
      (send-msg chan (format nil "~a: non-whitespace text input is required" sender))))
  (setq quoid
    (handler-case
      (lines-count filename)
      (condition() 0)))
  (with-open-file (file filename :direction :output :if-does-not-exist :create :if-exists :append)
    (progn
      (format file "~a@~d>>~a~%" sender (get-universal-time) arg)
      (send-msg chan (format nil "~a: quote #~d added" sender quoid))
      (ignore-errors (close file)))))

(defun lines-count(file)
  "Returns the number of lines in a file."
  (setq fp (open file :if-does-not-exist :error))
  (let ((lcnt 0))
    (progn
      (unwind-protect
        (loop
          (if
            (read-line fp nil)
            (setq lcnt (+ 1 lcnt))
            (return-from lines-count lcnt)))
        (ignore-errors (close fp))) lcnt)))

(defun get-line-by-num(file num)
  "Returns a line in a file."
  (setq fp (open file :if-does-not-exist :error))
  (unwind-protect
    (let ((lcnt 0))
      (loop
        (progn
          (setq line (read-line fp nil nil))
          (if
            (not line)
            (error "no quote with selected id")
            (if
              (= lcnt num)
              (return-from get-line-by-num line)))
          (setq lcnt (+ 1 lcnt)))))
    (ignore-errors (close fp))))
