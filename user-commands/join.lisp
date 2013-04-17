(require :cl-irc)

(setf (gethash "join" *registered-commands*)
      (lambda (msg connection)
	(irc:join connection (first (rest-words (cadr (irc::arguments msg)))))))
