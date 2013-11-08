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

(defun post-points (name number)
  (drakma:http-request
   (format nil
	   "http://localhost:8000/~a/points"
	   (drakma:url-encode name))
   :method :post
   :parameters `(("number" . ,(write-to-string number)))))

(defun post-jellybeans (name number)
  (drakma:http-request
   (format nil
	   "http://localhost:8000/~a/jellybeans"
	   (drakma:url-encode name))
   :method :post
   :parameters `(("number" . ,(write-to-string number)))))

(defun point-up (msg connection)
  (let ((name (first (rest-words (cadr (irc:arguments msg))))))
    (post-jellybeans (irc:source msg) -1)
    (post-points name 1)))
