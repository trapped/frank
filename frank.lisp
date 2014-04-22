;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Message processing utilities ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Split line by char
(defun split(line char)
  (loop for i = 0 then (1+ j)
        as j = (position char line :start i)
        collect (subseq line i j)
        while j))

;; Get message type
(defun get-type(line)
  (progn
    (setq done-split (split (nth 1 (split line #\:)) #\Space))
    (nth 1 done-split)))

;; Get message sender
(defun get-sender(line)
  (progn
    (setq done-split (split (nth 1 (split line #\:)) #\Space))
    (setq full-user (nth 0 done-split))
    (nth 0 (split full-user #\!))))

;; Get PRIVMSG recipient
(defun get-privmsg-recp(line)
  (progn
    (setq done-split (split (nth 1 (split line #\:)) #\Space))
    (nth 2 done-split)))

;; Get position nth occurrence of char in line
(defun get-occurrence(line char n)
  (progn
    (setq occ -1)
    (setq pos 0)
    (map 'nil #'
         (lambda(c)
           (progn
              (if (string= c char)
                  (setq occ (+ occ 1)))
              (if (= (- n 1) occ)
                  (return-from get-occurrence pos)
                  (setq pos (+ pos 1)))))
         line)))

;; Get message text
(defun get-text(line)
  (progn
    (subseq line (+ 1(get-occurrence line #\: 2)))))

;;;;;;;;;;;;;;;;;;;;;;
;;; Actual program ;;;
;;;;;;;;;;;;;;;;;;;;;;

;; Define constants
(setf server "irc.sorcery.net")
(setf port 6667)
(setf nick "FRANK")
(setf channel "#frank")
;(setf authorized-users '("." "trapped"))

;; Define session variables
(setf quitting nil)

;; Connect to server and save the socket
(setf socket (socket-connect port server))

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

;; Disconnect from server
(defun do-quit(sender message)
  (if t ;(member sender authorized-users)
      (progn
        (setf quitting t)
        (format socket "QUIT :~a~%" message))
      (send-msg (format nil "~a: user not authorized" sender))))

(defun do-randn(arg)
  (setq ))

;; Process chat commands
(defun process-cmd(line)
  (setq cmd (nth 1 (split (get-text line) #\Space)))
  (setq prefix (format nil "~a: " nick))
  (setq raw-arg (progn
    (if (<= (length (get-text line)) (+ (length cmd) (length prefix)))
      ""
      (subseq (get-text line) (+ (length cmd) (length prefix))))))
  (cond
    ((string= cmd "quit")  (do-quit (get-sender line) raw-arg))
    ((string= cmd "randn") (do-randn raw-arg))
    (t                    (send-msg (format nil "~a: unknown command '~a' :(" (get-sender line) cmd)))))

;; Process content of PRIVMSGs
(defun process-privmsg(line)
  (setq text (get-text line))
  (setq prefix (format nil "~a: " nick))
  (cond
    ((not (= (string>= text prefix) 0)) (if(string= text prefix :end1 (length prefix)) (process-cmd line)))
    (t                               (format t "~a <- ~a: ~a~%" (get-privmsg-recp line) (get-sender line) (get-text line)))))

(defun process-join(line)
  (format t ">> Joined channel ~a~%" (get-text line)))

(defun process-error(line)
  (if quitting
      (progn
        (socket-close socket)
        (quit))
      (format t ">> Error: ~a" (get-text line))))

;; Process received message
(defun process-msg(line)
  (setq type (get-type line))
  (cond
    ((string= type "NOTICE")            (format t ">> Notice: ~a~%" (get-text line)))
    ((string= type "PRIVMSG")           (process-privmsg line))
    ((string= (subseq line 0 4) "PING") (format socket "PONG ~a~%"  (subseq line 5)))
    ((string= type "JOIN")              (process-join    line))
    ((string= type "ERROR")             (process-error   line))))

;; Read forever from socket - start in a new thread
(defun read-loop()
  (loop(
    process-msg (read-line socket))))

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
(progn
  ; Start secondary reading thread
  (make-thread (lambda() (progn(thread-yield)(read-loop))))
  ; Loop waiting for commands
  (loop(progn
    ; Store command line input
    (setq input (read-line))
    (cond
      ((string= input "nick") (send-nick)) ; Send NICK command
      ((string= input "user") (send-user)) ; Send USER command
      ((string= input "join") (send-join)) ; Send JOIN command
      (t (send-msg input)))))) ; Send message to channel
