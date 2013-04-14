(require :cl-irc)

(setf (gethash "botsnack" *registered-commands*)
      (lambda (msg connection)
	(let* ((responses (vector "Yay!" ":D" "C:" ":3" "Whoop!"))
	      (privmsg-p
	       (not (char= (char (first (irc:arguments msg)) 0) #\#)))
	      (destination (if privmsg-p 
			       (irc:source msg)
			     (first (irc:arguments msg)))))
	  (irc:privmsg connection
		       destination
		       (elt responses (random (length responses)))))))
