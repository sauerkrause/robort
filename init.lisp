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

(load "common-defs.lisp")
(load "user-commands.lisp")
(in-package :robort)


(defun handle-join-message (msg)
  (user-command-helpers::handle-join msg (irc:connection msg)))
(defun handle-kick-message (msg)
  (user-command-helpers::handle-kick msg (irc:connection msg)))
(defun handle-privmsg-message (msg)
  (user-command-helpers::handle-command msg (irc:connection msg)))
(defun handle-invite-message (msg)
  (user-command-helpers::handle-invite msg (irc:connection msg)))
(defun handle-ping-message (msg)
  (apply #'irc:pong (irc:connection msg) (irc:arguments msg)))

(defun init-hooks (connection)
  (irc:add-hook connection 'irc::irc-join-message
		#'handle-join-message)
  (irc:add-hook connection 'irc::irc-kick-message
		#'handle-kick-message)
  (irc:add-hook connection 'irc::irc-privmsg-message
		#'handle-privmsg-message)
  (irc:add-hook connection 'irc::irc-invite-message
		#'handle-invite-message)
  (irc:add-hook connection 'irc::irc-ping-message
		#'handle-ping-message))

;; Do anything that needs to be done prior to reading the loops here.
(defun init (connection)
  ;; Maybe connect to the channels we want here.
  (dolist (s *channels*)
    (irc:join connection s))
  ;; Maybe initialize some hooks.
  (init-hooks connection))

;; handy reinit command.
(defun reinit (connection)
  ())
