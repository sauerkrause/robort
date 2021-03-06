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

(defun botsmack (msg connection)
  (let* ((responses (vector ":'(" ":C" "D:" "(ಥ_ಥ)" ":く" "ಠ_ಠ"))
	 (response (elt responses (random (length responses)))))
    (progn
      (irc:privmsg connection
		   (get-destination msg)
		   (format nil "~a" response))
      (post-jellybeans (irc:source msg) -1))))
