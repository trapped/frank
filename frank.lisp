;; Define static variables
(setf server "irc.sorcery.net")
(setf port 6667)
(setf nick "FRANK")
(setf channel "#frank")

;; Do actual stuff
(let ((client (socket-connect port server)))
  (unwind-protect
    (progn
      ;; Log
      (format t "Connecting to ~a:~%" server port)
      ;; Wait 5 seconds
      (sleep 5)
      ;; Send NICK, USER, and JOIN commands
      (format client "NICK ~a~C~C" nick #\return #\linefeed)
      (format client "USER ~a 0 * :frank bot~C~C" nick #\return #\linefeed)
      (format client "JOIN ~a~C~C" channel #\return #\linefeed)
      (loop
        (print (read-line client nil nil))
      )
    )
  )
)