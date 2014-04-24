;;;
;;; FRANK - *THE* IRC bot
;;; ---------------------
;;; 
;;; Inspired by the #frank
;;; channel on SorceryNet,
;;; THE ONE IRC bot: FRANK.
;;;

;; Other useful packages
(require "./txtproc.lisp")

;; Message processors
(loop
  for file in (directory "./processors/*")
  do(require (namestring file)))

;; Scripts (chat commands)
(loop
  for file in (directory "./scripts/*")
  do(require (namestring file)))

;; Constants
(setf server           "irc.sorcery.net")
(setf port             6667)
(setf nick             "FRANK")
(setf full-name        "frank bot")
(setf channels         '("#frank" "#er"))
(setf authorized-users '("." "trapped")) ; "." reserved for internal as Sorcery wouldn't allow users to use it anyway

;; Session variables
(setf quitting nil)
(setf joined   '()) ; To be filled with a list of integers -> indexes of keys of channels

;; Server connection socket
(setf socket nil)

(defun send-nick()
  "Sends the NICK command."
  (format socket "NICK ~a~%" nick))

(defun send-user()
  "Sends the USER command."
  (format socket "USER ~a 0 * :~a~%" nick full-name))

(defun send-join()
  "Sends as many JOIN commands as the number of channels specified."
  (loop
    for chan in channels
    do(format socket "JOIN ~a~%" chan)))

(defun send-msg(channel text)
  "Sends a normal chat message to the selected channel."
  (setq fixed-text (remove #\Newline text))
  (format socket "PRIVMSG ~a :~a~%" channel fixed-text))

(defun read-cmd(line)
  "Finds and executes received commands."
  (setq cmd (nth 1 (txt:split (txt:get-text line) #\Space)))
  (setq sym (find-symbol (format nil "DO-~a" (string-upcase cmd))))
  (setq prefix (format nil "~a: " nick))
  (setq raw-arg (progn
    (if (<= (length (txt:get-text line)) (+ (length cmd) (length prefix) 1))
      ""
      (subseq (txt:get-text line) (+ (length cmd) (length prefix) 1)))))
  (handler-case
    (if
      sym
      (funcall (symbol-function sym) (txt:get-privmsg-recp line) (txt:get-sender line) raw-arg)
      (send-msg (txt:get-privmsg-recp line) (format nil "~a: unknown command '~a' :(" (txt:get-sender line) cmd)))
    (condition (exc) (send-msg (txt:get-privmsg-recp line) (format nil "~a: error processing the command ('~a') :(" (txt:get-sender line) exc)))))

(defun read-msg(line)
  "Parses and processes received server messages."
  (setq type (txt:get-type line))
  (setq sym (find-symbol (format nil "PROCESS-~a" (string-upcase type))))
  (if
    sym
    (funcall (symbol-function sym) line)))

(defun read-loop()
  "Loops forever and reads from the connection, then passes the lines to read-msg()."
  (loop(progn
    (setq line (read-line socket))
    (read-msg line))))

;;;; Trap SIGINT
;;(defmacro set-signal-handler (signo &body body)
;;  (let ((handler (gensym "HANDLER")))
;;    (progn
;;      (cffi:defcallback ,handler :void ((signo :int))
;;        (declare (ignore signo))
;;        ,@body)
;;      (cffi:foreign-funcall "signal" :int ,signo :pointer (cffi:callback ,handler)))))
;;(set-signal-handler 2
;;  (format t ">> Quitting...")
;;  (progn
;;    (send-msg "Received SIGINT")
;;    (do-quit "." "Quitting")))

;; Main
(defun main()
  ; Connect to server
  (setf socket (socket-connect port server))
  ; Start secondary reading thread and get back to the main one
  (make-thread (lambda() (progn(thread-yield)(read-loop))))
  ; Loop waiting for commands
  (loop
    #|(progn
    ; Store command line input
    (setq input (read-line))
    (cond
      (t (send-msg input))))|#)) ; Send message to channel

;; Entry point
(main)