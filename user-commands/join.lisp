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

(defun join (msg connection)
  (let ((channel
	 (first (user-command-helpers::rest-words
		 (cadr (irc::arguments msg))))))
    (if channel
	(progn 
	  (irc:join connection channel)
	  (pushnew channel robort::*channels* :test #'equal)
	  (robort::persist-channels))
      (error 'user-command-helpers::flooped-command))))
(register-auth #'join)
(export 'join)
