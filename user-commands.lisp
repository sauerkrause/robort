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
(defvar *shell-loaded* (ql:quickload "trivial-shell"))
(require :trivial-shell)

;; need a package for these helpers separate from the user-commands
(defpackage :user-command-helpers
  (:use :common-lisp))
;; define a package we can shovel allo the things into.
(defpackage :user-commands
  (:use :common-lisp
	:user-command-helpers))

(in-package :user-command-helpers)

(load "configs/rcon.lisp")

(defun handle-command(connection)
  (lambda (msg)
    (say-to-rcons msg connection)))

(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part 
is replaced with replacement."
  (with-output-to-string (out)
			 (loop with part-length = (length part)
			       for old-pos = 0 then (+ pos part-length)
			       for pos = (search part string
						 :start2 old-pos
						 :test test)
			       do (write-string string out
						:start old-pos
						:end (or pos (length string)))
			       when pos do (write-string replacement out)
			       while pos)))

(defun say-to-rcons (msg connection)
  (let ((message (replace-all (format nil "~a" (cadr (irc:arguments msg))) "\"" "\\\"" )))
    (trivial-shell:shell-command 
     (format nil "mcrcon -s -H ~a -P ~a -p ~a \"say {~a} ~a\""
	     *rcon-host* 
	     *rcon-port* 
	     *rcon-passwd*
	     (irc:source msg)
	     message))))

;; this will walk the .lisp files in user-commands/
;; it should register each file it finds with a hash map.
;; then when a command is called, it should load the file.
(defun register-commands ()
  (progn 
    (loop for f in (directory "user-commands/*.lisp")
	  do (load f :verbose T))
    ()))
(register-commands)
