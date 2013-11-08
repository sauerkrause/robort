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

(require :do-urlencode)
(require :drakma)

(load "user-commands/common.lisp")

(defun get-jellybeans (name)
  (let ((stream
	 (drakma:http-request
	  (format nil
		  "http://localhost:8000/~a/jellybeans"
		  (do-urlencode:urlencode name))
	  :want-stream t)))
    (read stream)))

(defun jellybeans (msg connection)
  (let ((name (if (rest-words (cadr (irc:arguments msg)))
		  (first (rest-words (cadr (irc:arguments msg))))
		(irc:source msg))))
    (irc:privmsg connection (get-destination msg) 
		 (format nil "Jellybeans for ~a: ~d" name (get-jellybeans name)))))
(export 'jellybeans)
