(require :cl-irc)

(setf (gethash "say" *registered-commands*)
      (flet ((get-message (list)
	         (if (listp list)
		     (with-output-to-string (s)
		         (dolist (item list)
			     (if (stringp item)
				 (format s "~a " item)))))))
			  
	    (lambda (msg connection)
	      (let 
		  ((destination (first (irc:arguments msg))))
		(irc:privmsg connection 
			     destination 
			     (get-message (rest-words 
					   (cadr (irc::arguments msg)))))))))
