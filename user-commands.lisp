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
	   :rest-words
	   :register-auth
	   :forget-auth
	   :authed-funcall))

;; define a package we can shovel allo the things into.
(defpackage :user-commands
  (:use :common-lisp
	:user-command-helpers))

(in-package :user-command-helpers)

(load "configs/identification.lisp")

(define-condition flooped-command (error) nil)
(define-condition invalid-auth (error) nil)

(defparameter *protected-functions* (make-hash-table))

(defvar *ignore-map* (make-hash-table :test #'equal))

(defun needs-auth (fnsym)
  (gethash fnsym user-command-helpers::*protected-functions*))

(defun register-auth (fnsym)
  (setf (gethash fnsym user-command-helpers::*protected-functions*) fnsym))

(defun forget-auth (fnsym)
  (setf (gethash fnsym user-command-helpers::*protected-functions*) nil))

(defun priviligedp (nick)
  (member nick *allowed-users* :test #'equal))

(defun split-by-one-space (str)
  (loop for i = 0 then (1+ j)
	as j = (position #\Space str :start i)
	collect (subseq str i j)
	while j))

(export (defun first-word (str)
  (car (split-by-one-space str))))
(defun rest-words (str)
  (cdr (split-by-one-space str)))

(defun authed-funcall (nick fn &rest args)
  (when (and (needs-auth fn)
	     (not (priviligedp nick)))
    (error 'invalid-auth))
  (apply fn args))

(defun prefixedp (command)
  (let ((ret-val ()))
    (let ((prefix-results
	   (dolist (prefix robort::*prefixen*)
	     (unless (> (length prefix) (length command))
	       (let ((command-prefix (subseq command 0 (length prefix))))
		 (if (equalp command-prefix prefix)
		     (setf ret-val prefix))
		 robort::*prefixen*))))))
    ret-val))

(defun handle-invite (msg connection)
  (print (cadr (irc:arguments msg)))
  (setf (irc:source msg) (car *allowed-users*))
  (setf (cadr (irc:arguments msg)) (format nil "^join ~a" (cadr (irc:arguments msg))))
  (handle-command msg connection))

(defun botmessagep (str)
  (let ((open (search "<" str))
	(close (search "> " str)))
    (if (and open close (< open close))
	(subseq str (+ 2 close)))))

(defun botmessage-source (str)
  (let ((open (search "<" str))
	(close (search ">" str)))
    (if (and open close (< open close))
	(subseq str (+ 1 open) close))))

(defun contains-karma (msg)
  (let ((text (cadr (irc:arguments msg))))
    (or (search "++" text)
	(search "--" text))))

(defun karma-victim (msg)
  (dolist (word (split-by-one-space (cadr (irc:arguments msg))))
    (if (or (search "++" word)
	    (search "--" word))
	(return (subseq word 0 
			(if (search "++" word)
			    (search "++" word)
			  (search "--" word)))))))

(defun handle-karma (msg connection)
  ;; do some stuff with ++ and --
    (if (contains-karma msg)
	(flet ((incr-or-decr-for (msg)
				 (if (search "++" msg) 1 -1)))
	      (let ((victim (karma-victim msg))
		    (source (irc:source msg)))
		(if (and victim source)
		    (progn
		      (user-commands::post-points
		       victim
		       (incr-or-decr-for (cadr (irc:arguments msg))))
		      (user-commands::post-jellybeans source -1)))))))

(defun hashtagp (msg)
  (let ((text (cadr (irc:arguments msg))))
    (eql #\# (elt text 0))))

(defun handle-hashtag (msg connection)
  (let* ((text (cadr (irc:arguments msg)))
	 (begin (search "#" text))
	 (end (search " " text))
	 (term (if begin
		   (subseq text (+ 1 begin) end)))
	 (link (if term (user-commands::random-link-for-imgur-search term))))
    (irc:privmsg connection
		 (user-commands::get-destination msg)
		 (if link link (format nil "No related pic found for #~a" term)))))

(defun handle-kick (msg connection)
  (irc:privmsg connection
	       (user-commands::get-destination msg)
	       (user-commands::value-gandhi)))

(defun handle-command(msg connection)
  (cond
   ((contains-karma msg) (handle-karma msg connection))
   (t
    (let ((cmd
	   (let ((uncut-cmd (cadr (irc::arguments msg))))
	     (if (botmessagep uncut-cmd)
		 (let ((retval (botmessagep uncut-cmd)))
		   (setf (irc:source msg) (botmessage-source uncut-cmd))
		   (setf (cadr (irc:arguments msg)) retval)
		   retval)
	       uncut-cmd))))
      (when (and (not (gethash (irc:source msg) *ignore-map*))
		 (> (length (cadr (irc::arguments msg))) 1))
	(if (hashtagp msg)
	    (handle-hashtag msg connection)
	  (progn
	    (flet ((notice (message) (irc:notice connection (irc:source msg) message)))
		  (when (and (> (length cmd) 1) (prefixedp cmd))
		    (let* ((cmd-name (remove #\* (first-word (subseq cmd (length (prefixedp cmd))))))
			   (cmd-file-name (format nil "user-commands/~(~a~).lisp"
						  cmd-name)))
		      (if (and (probe-file cmd-file-name)
			       (find-symbol (common-lisp:string-upcase cmd-name) 'user-commands))
			  (let ((fnsym 
				 (fdefinition 
				  (find-symbol 
				   (common-lisp:string-upcase cmd-name) 
				   'user-commands)))
				(nick (irc:source msg)))
			    (handler-case
			     (authed-funcall nick fnsym msg connection)
			     (flooped-command 
			      ()(notice 
				 (format nil "Invalid usage of command: ~a" 
					 cmd-name)))
			     (invalid-auth
			      ()(notice
				 (format nil "You are not God. You cannot call ~a"
					 cmd-name)))))
			(progn 
			  (princ (cadr (irc::arguments msg)))
			  (irc:notice connection (irc:source msg)
				      (format nil "~a is not a valid command" cmd-name))))))))))))))

;; this will walk the .lisp files in user-commands/
;; and attempt to load them.
(defun register-commands ()
  (progn 
    (loop for f in (directory "user-commands/*.lisp")
	  do (load f :verbose T))
    ()))
(register-commands)
