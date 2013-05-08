;; Copyright 2013 Robert Allen Krause <robert.allen.krause@gmail.com>

;;     This file is part of Robort.

;;     Robort is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.

;;     Robort is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.

;;     You should have received a copy of the GNU General Public License
;;     along with Robort.  If not, see <http://www.gnu.org/licenses/>.
(require :cl-irc)

;; need a package for these helpers separate from the user-commands
(defpackage :user-command-helpers
  (:use :common-lisp)
  (:export :first-word
	   :rest-words))

;; define a package we can shovel allo the things into.
(defpackage :user-commands
  (:use :common-lisp
	:user-command-helpers))

(in-package :user-command-helpers)

(define-condition flooped-command (error) nil)

(defun split-by-one-space (str)
  (loop for i = 0 then (1+ j)
	as j = (position #\Space str :start i)
	collect (subseq str i j)
	while j))

(export (defun first-word (str)
  (car (split-by-one-space str))))
(defun rest-words (str)
  (cdr (split-by-one-space str)))

(defun handle-command(connection)
  (lambda (msg)
    (when (> (length (cadr (irc::arguments msg))) 1)
      (progn
	(let ((cmd (first-word (cadr (irc::arguments msg)))))
	  (when (and (> (length cmd) 1) (char= (char cmd 0) #\^))
	    (let* ((cmd-name (subseq cmd 1))
		   (cmd-file-name (format nil "user-commands/~a.lisp"
					  cmd-name)))
	      (if (and (probe-file cmd-file-name)
		       (load cmd-file-name)
		       (find-symbol (common-lisp:string-upcase cmd-name) 'user-commands))
		  (handler-case
		   (funcall (find-symbol 
			     (common-lisp:string-upcase cmd-name) 
			     'user-commands) msg connection)
		   (flooped-command 
		    ()(irc:notice connection (irc:source msg)
				  (format nil "Invalid usage of command: ~a" 
					  cmd-name))))
		(progn 
		  (princ (cadr (irc::arguments msg)))
		  (irc:notice connection (irc:source msg)
			      (format nil "~a is not a valid command" cmd-name)))))))))))

;; this will walk the .lisp files in user-commands/
;; it should register each file it finds with a hash map.
;; then when a command is called, it should load the file.
(defun register-commands ()
  (progn 
    (loop for f in (directory "user-commands/*.lisp")
	  do (load f :verbose T))
    ()))
(register-commands)
