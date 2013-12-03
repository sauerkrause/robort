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



(in-package :user-commands)
;; Defines 
;; *email-address* string
;; *smtp-server* string
;; *smtp-port* number
;; *ssl-p* bool
;; *username* string
;; *password* string
(load "configs/email-conf.lisp")


(defun email (msg connection)
  (flet ((reply (connection destination message)
		(irc:notice connection destination message)))
	(let* ((source (irc:source msg))
	       (subject-line (format nil "Message from ~a" source))
	       (destination 
		(user-command-helpers:first-word 
		 (get-message 
		  (user-command-helpers:rest-words (cadr (irc:arguments msg))))))
	       (word-list (rest-words (get-message (rest-words (cadr (irc::arguments msg))))))
	       (content 
		(format 
		 nil 
		 "~a~%~%~% - Brought to you by robort (tm)" 
		 (get-message word-list))))
	  (if (or (not destination) (not word-list))
	      (error 'user-command-helpers::flooped-command)
	    (if (and 
		 destination
		 word-list
		 (not (cl-smtp:send-email 
		       *smtp-server*
		       *email-address*
		       destination
		       subject-line
		       content
		       :ssl *ssl-p*
		       :port *smtp-port*
		       :authentication (list *username* *password*))))
		(irc:privmsg connection 
			     (get-destination msg) "ERROR: success")
	      (reply connection source "SUCCESS: failed"))))))
(register-auth #'email)
(export 'email)
