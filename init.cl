(ql:quickload "cl-irc")

(require :cl-irc)

(load "settings.cl")
(load "login-info.cl")

;; need this as *logins* should be closed over for this.
(defun get-connection (login)
    (irc:connect 
     :nickname (login-info-nick login)
     :server (login-info-server login)))

;; Do anything that needs to be done prior to reading the loops here.
(defun init (connection)
  (progn 
    ;; Maybe connect to the channels we want here.
    (dolist (s *servers*)
	      (irc:join connection s))
    ;; Maybe initialize some hooks.
    (init-hooks connection))
(defun init-hooks (connection)
  ())

;; Entry point
(let ((connection (get-connection *login*)))
  (progn
    (init connection)
    (irc:read-message-loop connection)))
