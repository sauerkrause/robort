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

(defun list-commands (msg connection)
	(let* ((word-list nil)
	       (privmsg-p
		(not (char= (char (first (irc:arguments msg)) 0) #\#)))
	       (destination (if privmsg-p 
				(irc:source msg)
			      (first (irc:arguments msg)))))
	  (labels ((symbol-internalp 
		    (sym pkg)
		    (multiple-value-bind
		     (symbol status)
		     (find-symbol (string sym) pkg)
		     (eq status :internal)))
		   (map-symbols (pkg fn)
		    (do-external-symbols
		     (key pkg)
		     (funcall fn key nil))))
		(progn
		  (map-symbols :user-commands
			       (lambda (key value)
				 (setf word-list (cons (string key) word-list))))
		  (irc:privmsg connection
			       destination
			       (if (listp word-list)
				   (with-output-to-string 
				     (s)
				     (dolist 
					 (word 
					  (sort word-list #'string-lessp))
				       (if (stringp word)
					   (format s "~a " word))))))))))
(export 'list-commands)
