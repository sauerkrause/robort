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

(defun replace-char-with-string (input-str char replacement)
  "Returns copy of input-str with instances of char replaced by replacement"
  (let ((ret (make-array 0
			 :element-type 'character
			 :fill-pointer 0
			 :adjustable t)))
    (loop for chr across input-str
	 do (if (eql chr char)
		(loop for tchr across replacement
		     do (vector-push-extend tchr ret))
		(vector-push-extend chr ret)))
    ret))

(defun get-message (list)
  (if (listp list)
      (with-output-to-string (s)
			     (dolist (item list)
			       (if (stringp item)
				   (format s "~a " item))))))

(defun privmsgp (msg)
  (not (char= (char (first (irc:arguments msg)) 0) #\#)))

(defun get-destination (msg)
  (if (privmsgp msg)
      (irc:source msg)
    (first (irc:arguments msg))))

(defun get-nick (msg)
  (irc:source msg))

(load "user-commands/common-macros.lisp")
