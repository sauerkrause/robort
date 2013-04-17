(in-package :user-commands)

(defun hi (msg connection)
  (let* ((privmsg-p
	  (not (char= (char (first (irc:arguments msg)) 0) #\#)))
	 (destination (if privmsg-p 
			  (irc:source msg)
			(first (irc:arguments msg))))
	 (nickname (irc:source msg))
	 (reply (format nil "~aHi!" 
			(if (not privmsg-p)
			    (format nil "~a: " nickname)
			  ""))))
    (irc:privmsg connection destination reply)))
