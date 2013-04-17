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
