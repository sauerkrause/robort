(require :cl-irc)
(in-package :user-commands)
(defun say (msg connection)
  nil)
;; (setf (gethash "say" *registered-commands*)
;;       (flet ((get-message (list)
;; 	         (if (listp list)
;; 		     (with-output-to-string (s)
;; 		         (dolist (item list)
;; 			     (if (stringp item)
;; 				 (format s "~a " item)))))))
;; 	    (lambda (msg connection)
;; 	      (let*
;; 		  ((privmsg-p
;; 		    (not (char= (char (first (irc:arguments msg)) 0) #\#)))
;; 		   (destination (if privmsg-p 
;; 				    (irc:source msg)
;; 				  (first (irc:arguments msg)))))
;; 		(irc:privmsg connection 
;; 			     destination  
;; 			     (get-message (rest-words 
;; 					   (cadr (irc::arguments msg)))))))))
