(require :cl-irc)

(setf (gethash "part" *registered-commands*)
      (lambda (msg connection)
	(irc:part connection (first (rest-words (cadr (irc::arguments msg)))))))
