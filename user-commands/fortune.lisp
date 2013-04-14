(require :cl-irc)

(ql:quickload "trivial-shell")
(require :trivial-shell)

(setf (gethash "fortune" *registered-commands*)
      (lambda (msg connection)
	(let* ((response (trivial-shell:shell-command "fortune"))
	       (fortune-list
		(loop for i = 0 then (1+ j)
		      as j = (position #\linefeed response :start i)
		      collect (subseq response i j)
		      while j))
	       (privmsg-p
	       (not (char= (char (first (irc:arguments msg)) 0) #\#)))
	      (destination (if privmsg-p 
			       (irc:source msg)
			     (first (irc:arguments msg)))))
	  (print response)
	  (dolist (line fortune-list)
	    (progn
	      (irc:privmsg connection
			   destination
			   line)
	      (sleep 0.5))))))
	  ;; (irc:privmsg connection
	  ;; 	       destination
	  ;; 	       response))))
