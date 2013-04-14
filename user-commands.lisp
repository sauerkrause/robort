(require :cl-irc)

(defun split-by-one-space (str)
  (loop for i = 0 then (1+ j)
	as j = (position #\Space str :start i)
	collect (subseq str i j)
	while j))

(defun first-word (str)
  (car (split-by-one-space str)))
(defun rest-words (str)
  (cdr (split-by-one-space str)))

(defparameter *registered-commands* (make-hash-table :test #'equal))

(defun handle-command(connection)
  (lambda (msg)
    (progn
      (let* ((cmd (first-word (cadr (irc::arguments msg))))
	     (cmd-name (subseq cmd 1))
	     (cmd-file-name (format nil "user-commands/~a.lisp" cmd-name)))
	(if (char= (char cmd 0) #\^)
	    (if (and (probe-file cmd-file-name)
		     (load cmd-file-name)
		     (gethash cmd-name *registered-commands*))
		(funcall (gethash cmd-name *registered-commands*) msg connection)
	      (progn 
		(princ (cadr (irc::arguments msg)))
		(irc:privmsg connection (irc:source msg)
			     (format nil "~a is not a valid command" cmd-name))))
	  (princ ""))))))

;; this will walk the .lisp files in user-commands/
;; it should register each file it finds with a hash map.
;; then when a command is called, it should load the file.
(defun register-commands ()
  (progn 
    (loop for f in (directory "user-commands/*.lisp")
	  do (load f :verbose T))
    ()))
(register-commands)
