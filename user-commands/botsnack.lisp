(require :cl-irc)

(setf (gethash "botsnack" *registered-commands*)
      (lambda (msg connection)
	(let ((responses (vector "Yay!" ":D" "C:" ":3" "Whoop!"))
	      (destination (first (irc:arguments msg))))
	  (irc:privmsg connection
		       destination
		       (elt responses (random (length responses)))))))
