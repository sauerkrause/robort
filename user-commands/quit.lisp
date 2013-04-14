(setf (gethash "quit" *registered-commands*)
      (lambda (msg connection)
	(exit)))
