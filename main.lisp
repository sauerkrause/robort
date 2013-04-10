(ql:quickload "cl-irc")

(require :cl-irc)

(load "settings.lisp")
(load "common-defs.lisp")
(load "init.lisp")

;; need this as *logins* should be closed over for this.
(defun get-connection (login)
  (progn
    (print (login-info-nick login))
    (print (login-info-server login))
    (irc:connect
     :server (login-info-server login)
     :nickname (login-info-nick login))))

(defun reload (connection)
  (progn
    ;; Use quit, not die or disconnect.
    (irc:quit connection)
    (print "Died connection hopefully")))

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
       (reload-required () (reload connection))))))

(loop
 (main))
