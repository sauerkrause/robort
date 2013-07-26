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

(in-package :user-commands)

(defmacro with-gensyms ((&rest names) &body body)
  `(let ,(loop for n in names collect `(,n (gensym)))
     ,@body))

(defun rand-value (list-values)
  (let ((item (elt list-values (if (< 1 (length list-values))
		       (random (length list-values))
		     0))))
    (if (stringp item)
	item
      (eval item))))

(defmacro name-literal (name list-values)
  `(defun ,name (msg connection)
       (irc:privmsg connection
		    (get-destination msg)
		    (rand-value ,list-values))))

(defmacro value-literal (name list-values)
  `(defun ,(intern 
	    (string-upcase (concatenate 
			    'string 
			    "value-" 
			    (string name)))) ()
     (rand-value ,list-values)))

(defmacro literal-literal (name list-values)
  `(defun ,(intern (string-upcase
		    (concatenate 'string
				 "literal-"
				 (string name)))) ()
				 ,list-values))

(defmacro define-literal (name values &key needs-auth)
  (with-gensyms (index-value
                 list-values)
                `(progn
		   (let ((,list-values ,values))
		     (name-literal ,name ,list-values)
		     (value-literal ,name ,list-values)
		     (literal-literal ,name ,list-values))
		   (user-command-helpers:forget-auth (function ,name))
                   (when ,needs-auth
                     (user-command-helpers:register-auth (function ,name)))
                   (export ',name))))
