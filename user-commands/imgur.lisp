(in-package :user-commands)
(require :cl-irc)
(require :drakma)
(require :do-urlencode)
(require :cl-json)
(require :flexi-streams)
(load "configs/imgur-id.lisp")
(load "user-commands/common.lisp")

(defun imgur-required-headers ()
  '(("Authorization" . "Client-ID 091f8126f9a8c3c")))

;; Assume sequences.
(defun random-item (items)
  (if items (elt items (if (< 1 (length items))
		 (random (length items))
	       0))))

(defun links-for (response)
  (setf (flexi-streams:flexi-stream-external-format response) :utf-8)
  (let* ((json-out (cl-json:decode-json response))
	 (image-objs (cdr (assoc :data json-out))))
    (mapcar (lambda (item)
	      (format nil "~@[~a ~]~@[~a ~]~@[~a ~]" 
		      (cdr (assoc :title item))
		      (cdr (assoc :link item))
		      (cdr (assoc :description item))))
	    image-objs)))

(defun imgur-search-streamed (term)
  (let ((search-url (format nil "https://api.imgur.com/3/gallery/search?q=~a"
			    (do-urlencode:urlencode term))))
    (drakma:http-request search-url :additional-headers (imgur-required-headers) :want-stream t)))

(defun random-link-for-imgur-search (term)
  (random-item (links-for (imgur-search-streamed term))))

(defun imgur (msg connection)
  (let* ((term (first (rest-words (cadr (irc:arguments msg)))))
	 (link (random-link-for-imgur-search term)))
    (irc:privmsg connection
		 (get-destination msg)
		 (if link link (format nil "No related pic found for #~a" term)))))
(export 'imgur)
