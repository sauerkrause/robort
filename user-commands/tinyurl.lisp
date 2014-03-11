(in-package :user-commands)

(require :cl-ppcre)

(defun tinyurl-for (url)
  (let ((req-url (format nil
			 "http://tinyurl.com/api-create.php"
			 )))
    (print req-url)
    (drakma:http-request req-url :method :post
			 :parameters `(("url" . ,url)))))

(defun extract-argument (msg)
  (user-command-helpers::split-by-one-space (cadr (irc:arguments msg))))

(defun tinyurl (msg connection)
  (let ((url (tinyurl-for (elt (extract-argument msg) 1))))
    (print url)
    (irc:privmsg connection
		 (get-destination msg)
		 (if url url (format nil "Bogus url")))))
