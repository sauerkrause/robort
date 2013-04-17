(require :cl-irc)
(ql:quickload "cl-smtp")
(require :cl-smtp)

(in-package :user-commands)
;; Defines 
;; *email-address* string
;; *smtp-server* string
;; *smtp-port* number
;; *ssl-p* bool
;; *username* string
;; *password* string
(load "configs/email-conf.lisp")
(setf cl-smtp::*debug* t)
(defun email (msg connection)
  (flet ((get-message (list)
		      (if (listp list)
			  (with-output-to-string (s)
						 (dolist (item list)
							 (if (stringp item)
							     (format s "~a " item))))))
	 (reply (connection destination message)
		(irc:notice connection destination message)))
	(let* ((source (irc:source msg))
	       (subject-line (format nil "Message from ~a" source))
	       (destination 
		(user-command-helpers:first-word 
		 (get-message 
		  (user-command-helpers:rest-words (cadr (irc:arguments msg))))))
	       (content 
		(format 
		 nil 
		 "~a~%~%~% - Brought to you by robort (tm)" 
		 (get-message (rest-words (get-message (rest-words (cadr (irc::arguments msg)))))))))
		(if (not (cl-smtp:send-email 
			  *smtp-server*
			  *email-address*
			  destination
			  subject-line
			  content
			  :ssl *ssl-p*
			  :port *smtp-port*
			  :authentication (list *username* *password*)))
		    (irc:privmsg connection (first (irc:arguments msg)) "ERROR: success")
		  (reply connection source "SUCCESS: failed")))))
