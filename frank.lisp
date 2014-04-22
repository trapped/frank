;; Define static variables
(setf server "irc.sorcery.net")
(setf port 6667)
(setf nick "FRANK")
(setf channel "#frank")

;; Connect to server and save the socket
(setf socket (socket-connect port server))

;; Reads forever from socket - to be started on a new thread
(defun read-loop()
  (progn
    (loop(
    print (read-line socket)))))

;; Send NICK command
(defun send-nick()
  (format socket "NICK ~a~%" nick))

;; Send USER command
(defun send-user()
  (format socket "USER ~a 0 * :frank bot~%" nick))

;; Send JOIN command
(defun send-join()
  (format socket "JOIN ~a~%" channel))

;; Send normal message to channel
(defun send-msg(text)
  (format socket "PRIVMSG ~a :~a~%" channel text))

;; Main
(progn
       (make-thread (lambda() (progn(thread-yield)(read-loop))))
       (print "i'm here")
       (loop(progn
             (setq input (read-line))
             (print input)
             (cond
                   ((string-equal input "nick") (send-nick))
                   ((string-equal input "user") (send-user))
                   ((string-equal input "join") (send-join))
                   (t (send-msg input))))))