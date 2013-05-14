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

(defun message-string (msg)
  (cadr (irc::arguments msg)))

(defun define (msg connection)
  (let ((nickname (irc:source msg))
	(reply ""))
    (progn
      (let ((msg-list (rest-words (message-string msg))))
	;; error out before attempting anything when we don't have the args
	(progn 
	  (when (< (length msg-list) 2)
	    (error 'user-command-helpers::flooped-command))
	  (let ((fname (first msg-list))
		(fdef (rest msg-list)))
	    ;; define the function and maybe write to a file.
	    ())))
      (irc:privmsg connection (get-destination msg)
		   (format nil "~@[~a: ~]Defined!"
			   (if (not (privmsgp msg))
			       nickname))))))

(user-command-helpers::register-auth #'define)

(export 'define)
