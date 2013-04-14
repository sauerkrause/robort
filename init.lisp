(require :cl-irc)

(load "common-defs.lisp")
(load "user-commands.lisp")
(load "user-commands/reload.lisp")
(defun init-hooks (connection)
  (irc:add-hook connection 'irc::irc-privmsg-message
		(handle-command connection)))
  	    ;; #'(lambda (msg)
	    ;; 	(print msg)
  	    ;; 	(error 'reload-required))))

;; Do anything that needs to be done prior to reading the loops here.
(defun init (connection)
  (progn
    ;; Maybe connect to the channels we want here.
    (dolist (s *channels*)
	      (irc:join connection s))
    ;; Maybe initialize some hooks.
    (init-hooks connection)))
