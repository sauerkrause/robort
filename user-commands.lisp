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
      (register-commands)
      (let ((cmd (first-word (cadr (irc::arguments msg)))))
	(when (char= (char cmd 0) #\^)
	  (let* ((command (subseq cmd 1))
		 (anon-fn (gethash command *registered-commands*)))
	    (if anon-fn
		(progn
		  (funcall anon-fn msg connection))
	      (format T "~a Not a registered command" command)))))
      (princ ""))))

;; this will walk the .lisp files in user-commands/
;; it should register each file it finds with a hash map.
;; then when a command is called, it should load the file.
(defun register-commands ()
  (progn 
    (loop for f in (directory "user-commands/*.lisp")
	  do (load f :verbose T))
    ()))
(register-commands)
