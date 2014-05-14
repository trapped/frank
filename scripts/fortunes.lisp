;;;
;;; Fortunes
;;; --------
;;; Outputs short-medium
;;; fortunes from fortune(1)
;;; (fortune-mod).
;;; -iso
;;;

(defun do-fortune(chan sender arg)
  "Tells fortunes. Usage: fortune"
  (with-open-stream
	(s1 (ext:run-program "fortune" :arguments '("-iso") :output :stream))
	(with-output-to-string (out)
	  (progn
		(copy-stream s1 out)
		(send-msg chan
		  (txt:replace-all
		    (txt:replace-all
			  (get-output-stream-string out)
			    (format nil "~%")
				  " ")
			(format nil "~C" #\tab)
			" "))))))
