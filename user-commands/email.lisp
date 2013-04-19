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
(ql:quickload "cl-smtp")
(require :cl-smtp)

;; Defines 
;; *email-address* string
;; *smtp-server* string
;; *smtp-port* number
;; *ssl-p* bool
;; *username* string
;; *password* string
(load "configs/email-conf.lisp")

(defun reply (connection source message)
  (irc:notice connection destination message))

(setf (gethash "email" *registered-commands*)
      (flet ((get-message (list)
			  (if (listp list)
			      (with-output-to-string (s)
						     (dolist (item list)
						       (if (stringp item)
							   (format s "~a " item)))))))
	    (lambda (msg connection)
	      (let* ((source (irc:source msg))
		     (subject-line (format nil "Message from ~a" source))
		     (destination (first-word (get-message (rest-words (cadr (irc::arguments msg))))))
		     (content 
		      (format 
		       nil 
		       "~a~%~%~% - Brought to you by robort (tm)" 
		       (get-message (rest-words (get-message (rest-words (cadr (irc::arguments msg)))))))))
		(if (not (cl-smtp:send-email "smtp.gmail.com" "robort.krause@gmail.com"
				    destination subject-line content :port 587
			      :authentication '("robort.krause" "hunter2!") :ssl t))
		    (irc:privmsg connection (first (irc:arguments msg)) "ERROR: success")
		  (reply connection source "SUCCESS: failed"))))))
