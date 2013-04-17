(require :cl-irc)

(setf (gethash "list-commands" *registered-commands*)
      (lambda (msg connection)
	(let* ((word-list nil)
	       (privmsg-p
		(not (char= (char (first (irc:arguments msg)) 0) #\#)))
	       (destination (if privmsg-p 
				(irc:source msg)
			      (first (irc:arguments msg)))))
	  (progn
	    (maphash (lambda (key value)
		       (setf word-list (cons key word-list)))
		     *registered-commands*)
	    (irc:privmsg connection
			 destination
			 (if (listp word-list)
			     (with-output-to-string 
			       (s)
			       (dolist (word (sort word-list #'string-lessp))
				 (if (stringp word)
				     (format s "~a " word))))))))))
