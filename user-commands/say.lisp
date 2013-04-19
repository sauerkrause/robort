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
