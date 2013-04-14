;; Note, must be loaded after user-commands.lisp
(setf (gethash "reload" *registered-commands*) 
      (lambda (msg connection)
	(progn
	  (format T "msg: ~a" msg)
	  (print "Reloading")
	  (reload connection))))
