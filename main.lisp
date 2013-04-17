(defpackage :robort
  (:use :common-lisp :common-lisp-user)
  (:export :reinitialize
	   :*registered-commands*))
(in-package :robort)

(ql:quickload "cl-irc")

(require :cl-irc)

(load "settings.lisp")
(load "common-defs.lisp")

;; need this as *logins* should be closed over for this.
(defun get-connection (login)
  (progn
    (print (login-info-nick login))
    (print (login-info-server login))
    (irc:connect
     :server (login-info-server login)
     :nickname (login-info-nick login))))

(defun reinitialize (connection)
  (progn
    ;; Use quit, not die or disconnect.
    (irc:quit connection)
    (print "Died connection hopefully")))
(export :reinitialize)

;; Entry point
(defun main ()
  (progn
    (load "settings.lisp")
    (load "common-defs.lisp")
    (load "init.lisp")
    (let ((connection (get-connection *login*)))
      (handler-case
       (progn
	 (init connection)
	 (irc:read-message-loop connection))
       (reinitialize-required () (reinitialize connection))))))

(load "init.lisp")


(loop
 (main))
