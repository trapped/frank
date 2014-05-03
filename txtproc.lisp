;;;
;;; Text processing utilities
;;; -------------------------
;;; 
;;; To process text and extract
;;; useful data expressed with
;;; the IRC protocol.
;;;

(defpackage txt
  (:export
    #:smember    #:get-privmsg-recp
    #:split      #:get-occurrence
    #:get-type   #:get-text
    #:get-sender))

(in-package :txt)

(defun smember(itm lst)
  "Checks if a string is contained into a list (of strings)."
  (loop
    for item in lst
    do(if (string= itm item)
          (return-from smember t)))
  nil)

(defun split(line char)
  "Splits a line by a character."
  (loop for i = 0 then (1+ j)
    as j = (position char line :start i)
    collect (subseq line i j)
    while j))

(defun get-type(line)
  "Parses and returns the type of the server message."
  (setq split-prefix (split (nth 0 (split line #\:)) #\Space))
  (setq split-header (split (nth 1 (split line #\:)) #\Space))
  (if (= (length split-prefix) 2) (nth 0 split-prefix) (nth 1 split-header)))

(defun get-sender(line)
  "Parses and returns the sender of the server message."
  (setq done-split (split (nth 1 (split line #\:)) #\Space))
  (setq full-user (nth 0 done-split))
  (nth 0 (split full-user #\!)))

(defun get-privmsg-recp(line)
  "Parses and returns the recipient of the server PRIVMSG message."
  (setq done-split (split (nth 1 (split line #\:)) #\Space))
  (nth 2 done-split))

(defun get-occurrence(line char n)
  "Parses and returns the nth occurrence of char in line."
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
    line))

(defun get-text(line)
  "Parses and returns the text of the server message."
  (subseq line (+ 1(get-occurrence line #\: 2))))

(provide "txt")
