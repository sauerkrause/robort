(require :cl-irc)

(setf (gethash "list" *registered-commands*)
      (lambda (msg connection)
	(let* ((privmsg-p
		(not (char= (char (first (irc:arguments msg)) 0) #\#)))
	       (destination (if privmsg-p
				(irc:source msg)
			      (first (irc:arguments msg)))))
	  (irc:privmsg 
	   connection
	   destination
	   (format nil "(cons a (cons b (cons c ()))) ;; hyuk hyuk did you mean list-commands?")))))
